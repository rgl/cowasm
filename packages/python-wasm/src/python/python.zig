const python = @cImport(@cInclude("Python.h"));
const std = @import("std");
pub const General = error{ OverflowError, RuntimeError };

var didInit = false;
var globals: *python.PyObject = undefined;
pub fn init() void {
    if (didInit) return;
    didInit = true;
    // std.debug.print("calling Py_Initialize()...\n", .{});
    python.Py_Initialize();
    // std.debug.print("success!\n", .{});
    globals = python.PyDict_New();
}

pub fn exec(s: [*:0]const u8) !void {
    // std.debug.print("exec '{s}'\n", .{s});
    // Returns 0 on success or -1 if an exception was raised. If there was an error, there is no way to get the exception information.
    // std.debug.print("PyRun_String: Py_file_input -- '{s}'\n", .{s});
    var pstr = python.PyRun_String(s, python.Py_file_input, globals, globals);
    if (pstr == null) {
        python.PyErr_Clear();
        // failed - some sort of exception got raised.
        std.debug.print("failed to run '{s}'\n", .{s});
        return General.RuntimeError;
    }
    // it worked.  We don't use the return value for anything.
    python.Py_DECREF(pstr);
}

pub fn eval(allocator: std.mem.Allocator, s: [*:0]const u8) ![]u8 {
    // std.debug.print("eval '{s}'\n", .{s});
    var pstr = python.PyRun_String(s, python.Py_eval_input, globals, globals);
    if (pstr == null) {
        python.PyErr_Clear();
        std.debug.print("eval -- PyRun_String failed\n", .{});
        return General.RuntimeError;
    }
    defer python.Py_DECREF(pstr);

    var rep = python.PyObject_Repr(pstr);
    if (rep == null) {
        python.PyErr_Clear();
        std.debug.print("eval -- PyObject_Repr failed\n", .{});
        return General.RuntimeError;
    }
    defer python.Py_DECREF(rep);
    // std.debug.print("rep ptr = {*}\n", .{rep});
    const str_rep = python.PyUnicode_AsUTF8(rep);

    // std.debug.print("str_rep = {s}\n", .{str_rep});
    return try std.fmt.allocPrint(
        allocator,
        "{s}",
        .{str_rep},
    );
}

// TODO: actually parse and send the argv to Py_BytesMain.  Below we
// actually just send ['python'] and that is it.
pub fn repl(allocator: std.mem.Allocator, argv_json: [*:0]const u8) !void {
    _= allocator;
    _ = argv_json;
    //     std.debug.print("repl argv_json='{s}'\n", .{argv_json});
    //     var p = std.json.Parser.init(allocator, false);
    //     defer p.deinit();

    //     var obj = try p.parse(argv_json[0..std.mem.len(argv_json)]);
    //     defer obj.deinit();

    //     var obj0 = obj.root.Object.get("0").?;
    //     std.debug.print("parsed[0]='{s}'\n", .{obj0.String});

    //     var obj1 = obj.root.Object.get("1").?;
    //     if (obj1.String.len > 0) {
    //         std.debug.print("parsed[1]='{s}'\n", .{obj1.String});
    //     }

    //     var argv: [*c][*c]u8 = @ptrCast([*c][*c]u8, @alignCast(@alignOf([*:0]u8), std.c.malloc(1 * @sizeOf([*:0]u8))));
    //     // cast back and forth to int to get rid of const
    //     //argv[0] = @intToPtr([*:0]u8, @ptrToInt(obj0.String.ptr));

    const s = "python";
    var argv: [*c][*c]u8 = @ptrCast([*c][*c]u8, @alignCast(@alignOf([*:0]u8), std.c.malloc(1 * @sizeOf([*:0]u8))));
    argv[0] = @intToPtr([*:0]u8, @ptrToInt(s));
    // std.debug.print("calling Py_BytesMain()...\n", .{});
    const r = python.Py_BytesMain(1, argv);
    _ = r;
    // std.debug.print("Py_Main exited with code {}\n", .{r});
}

// var importedJson = false;
// var json: *python.PyObject = undefined;
// pub fn toJSON(allocator: std.mem.Allocator, s: [*:0]const u8) ![]u8 {
//     // Import the JSON module
//     if (!importedJson) {
//         json = python.PyImport_ImportModule("json");
//         if (json == null) {
//             python.PyErr_Clear();
//             std.debug.print("toJSON -- failed to import json module\n", .{});
//             return General.RuntimeError;
//         }
//         importedJson = true;
//     }
//     // Evaluate s:
//     var pstr = python.PyRun_String(s, python.Py_eval_input, globals, globals);
//     if (pstr == null) {
//         python.PyErr_Clear();
//         std.debug.print("toJSON -- PyRun_String failed\n", .{});
//         return General.RuntimeError;
//     }
//     defer python.Py_DECREF(pstr);

//     // Convert to JSON

// }

const eql = std.mem.eql;
const expect = std.testing.expect;
const test_allocator = std.testing.allocator;

test "exec" {
    init();
    try exec("a = 2 + 3");
    const a = try eval(test_allocator, "a");
    defer test_allocator.free(a);
    try expect(eql(u8, a, "5"));
}

test "exec of longer multi-statement code" {
    init();
    try exec("def f(n):\n    return n*2\n\na=f(1010)");
    const a = try eval(test_allocator, "a");
    defer test_allocator.free(a);
    try expect(eql(u8, a, "2020"));
}

test "eval" {
    init();
    const a = try eval(test_allocator, "sum(range(101))");
    defer test_allocator.free(a);
    try expect(eql(u8, a, "5050"));
}

test "exec and eval" {
    init();
    try exec("w = 10; v = range(101)");
    const a = try eval(test_allocator, "sum(v)");
    defer test_allocator.free(a);
    try expect(eql(u8, a, "5050"));
    const b = try eval(test_allocator, "w+1");
    defer test_allocator.free(b);
    try expect(eql(u8, b, "11"));
}

// pub fn add() void {
//     init();
//     _ = python.PyRun_SimpleString("print('1 + ... + 100 = ', sum(range(101)))\n");
// }

// test "do something" {
//     _ = add();
//     python.Py_FinalizeEx();
// }
