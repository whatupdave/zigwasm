const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("main", "src/main.zig");
    lib.setBuildMode(mode);
    lib.setTarget(builtin.Arch.wasm32, .freestanding, .none);

    b.default_step.dependOn(&lib.step);

    b.installArtifact(lib);
}
