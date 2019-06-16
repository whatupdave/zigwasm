import { createRenderer } from "./renderer";

const renderer = createRenderer();

// TODO: figure out how to get these types properly
declare const WebAssembly: any;

fetch("./main.wasm", { cache: "no-store" })
  .then(response => response.arrayBuffer())
  .then(bytes => WebAssembly.instantiate(bytes, { renderer, console }))
  .then(wasm => renderer.init(wasm.instance.exports));
