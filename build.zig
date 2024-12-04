const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    var day: usize = 1;
    while (day < 25) : (day += 1) {
        const dayString = b.fmt("{:0>2}", .{day});
        const path = b.fmt("src/{s}/solution.zig", .{dayString});

        const exe = b.addExecutable(.{
            .name = dayString,
            .root_source_file = b.path(path),
            .target = target,
            .optimize = mode,
        });

        const build_test = b.addTest(.{
            .root_source_file = b.path(path),
            .target = target,
            .optimize = mode,
        });

        // install step
        const install_cmd = b.addInstallArtifact(exe, .{});
        const install_step = b.step(
            b.fmt("install_{s}", .{dayString}),
            b.fmt("Install {s}.exe", .{dayString}),
        );
        install_step.dependOn(&install_cmd.step);

        // test step
        const run_test = b.addRunArtifact(build_test);
        const test_step = b.step(
            b.fmt("test_{s}", .{dayString}),
            b.fmt("Run tests in {s}", .{path}),
        );
        test_step.dependOn(&run_test.step);

        // run step
        const run_cmd = b.addRunArtifact(exe);
        const run_step = b.step(
            dayString,
            b.fmt("Run {s}", .{dayString}),
        );
        run_step.dependOn(&run_cmd.step);
    }
}
