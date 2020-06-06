const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const web = b.option(bool, "web", "create web build") orelse false;

    const exe = b.addExecutable("wasm-test", "src/main.zig");
    exe.setBuildMode(mode);
    exe.linkSystemLibrary("sdl2");

    if (web) {
        exe.setTarget(.{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding
        });
    }
    

    b.default_step.dependOn(&exe.step);

    b.installArtifact(exe);
}
