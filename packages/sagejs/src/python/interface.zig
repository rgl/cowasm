const std = @import("std");
const python = @import("./python.zig");

// extern fn exec_cb(ptr: [*]const u8, len: usize) void;

// export fn exec(s: [*:0]const u8) void {
//     var r = pari.exec(s) catch |err| {
//         //todo
//         std.debug.print("pari interface exec error: {}\n", .{err});
//         return;
//     };
//     exec_cb(r, std.mem.lenZ(r));
//     std.c.free(r);
// }