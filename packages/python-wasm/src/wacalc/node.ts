import wasmImport from "../wasm/import-node";
import wasmImportNoWorker from "../wasm/worker/node";
import { _init, wasm, terminal as _terminal } from "./index";
import { join } from "path";

const WACALC_WASM = "wacalc.wasm";

// Our tiny termcap file only has one entry, which is for xterm
// so that's all we give you, even if you have a different terminal.
const TERM = "xterm-256color";

export async function init({
  debug,
}: {
  debug?: boolean;
} = {}) {
  const path = __dirname;

  const env = {
    ...process.env,
    TERM,
    TERMCAP: join(path, "..", "termcap"),
    PS1: "zash$ ",
  };
  //PS1: 'zash $(pwd | sed "s|^$HOME|~|")$ '

  await _init({
    programName: process.env.PROGRAM_NAME, // real name or made up name
    wasmSource: join(path, WACALC_WASM),
    wasmImport: debug ? wasmImportNoWorker : wasmImport,
    fs: [{ type: "native" }],
    env,
  });
}

async function terminal({
  argv,
  debug = false,
}: {
  argv: string[];
  debug?: boolean;
}): Promise<number> {
  await init({ debug });
  return await _terminal(argv);
}

export { terminal, wasm };