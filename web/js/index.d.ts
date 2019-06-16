// TODO: investigate code generating this file from zig

// these functions are callable from javascript
export interface ZigExports {
  // export fn init() void {}
  init(): void;

  // export fn onKey(key_code: c_int, key_down: bool) void {
  onKey(key_code: number, key_down: boolean): void;

  // export fn loadAssetsCallback() void {
  loadAssetsCallback(): void;

  // export fn tick(delta: f32) void {
  tick(delta: number): void;

  memory: {
    buffer: {
      slice(ptr: number, len: number): ArrayBufferView;
    };
  };
}
