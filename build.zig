const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    var day: usize = 1;
    while (day <= 11) : (day += 1) {
        const wf = b.addWriteFiles();
        const dayString = b.fmt("{:0>2}", .{day});

        const srcPath = b.fmt("src/{s}", .{dayString});
        _ = wf.addCopyDirectory(b.path(srcPath), "", .{});

        const solution = b.addModule("solution", .{
            .root_source_file = b.path(b.fmt("src/{s}/solution.zig", .{dayString})),
        });

        const begin =
            \\ const std = @import("std");
            \\ pub const solution = @import("solution");
            \\ test { std.testing.refAllDecls(@This()); }
            \\ pub fn main() !void {
            \\     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
            \\     const input = @embedFile("input.txt");
            \\     std.debug.print("{any}\n", .{solution.
        ;
        const end = "(gpa.allocator(), input)});}";
        const part_sources = [_][]const u8{ begin ++ "part_one" ++ end, begin ++ "part_two" ++ end };

        var part: usize = 1;
        for (part_sources) |source_code| {
            const name = b.fmt("{s}_{d}", .{ dayString, part });
            const path = wf.add(b.fmt("{d}.zig", .{name}), source_code);

            const part_exe = b.addExecutable(.{
                .name = name,
                .root_source_file = path,
                .target = target,
                .optimize = mode,
            });
            part_exe.root_module.addImport("solution", solution);

            // install step
            const install_cmd = b.addInstallArtifact(part_exe, .{});
            const install_step = b.step(b.fmt("install_{s}", .{name}), "Install");
            install_step.dependOn(&install_cmd.step);

            // run step
            const run_cmd = b.addRunArtifact(part_exe);
            const run_step = b.step(name, "Run");
            run_step.dependOn(&run_cmd.step);
            part += 1;
        }

        const exe = b.addExecutable(.{
            .name = dayString,
            .root_source_file = b.path(b.fmt("src/{s}/solution.zig", .{dayString})),
            .target = target,
            .optimize = mode,
        });

        // install step
        const install_cmd = b.addInstallArtifact(exe, .{});
        const install_step = b.step(b.fmt("install_{s}", .{dayString}), "Install");
        install_step.dependOn(&install_cmd.step);

        // run step
        const run_cmd = b.addRunArtifact(exe);
        const run_step = b.step(dayString, "Run");
        run_step.dependOn(&run_cmd.step);

        // test step
        const build_test = b.addTest(.{
            .root_source_file = b.path("src/test.zig"),
            .target = target,
            .optimize = mode,
        });

        build_test.root_module.addImport("solution", solution);
        const run_test = b.addRunArtifact(build_test);
        const test_step = b.step(b.fmt("test_{s}", .{dayString}), "Run tests");
        test_step.dependOn(&run_test.step);
    }
}
