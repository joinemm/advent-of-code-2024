const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    var day: usize = 1;
    while (day < 25) : (day += 1) {
        const dayString = b.fmt("{:0>2}", .{day});

        const wf = b.addWriteFiles();
        _ = wf.addCopyDirectory(b.path(b.fmt("src/{s}", .{dayString})), "", .{});

        const begin =
            \\ const std = @import("std");
            \\ pub const solution = @import("solution.zig");
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
            const path = wf.add(b.fmt("{d}.zig", .{part}), source_code);

            const exe = b.addExecutable(.{
                .name = name,
                .root_source_file = path,
                .target = target,
                .optimize = mode,
            });

            // install step
            const install_cmd = b.addInstallArtifact(exe, .{});
            const install_step = b.step(b.fmt("install_{s}", .{name}), "Install");
            install_step.dependOn(&install_cmd.step);

            // run step
            const run_cmd = b.addRunArtifact(exe);
            const run_step = b.step(name, "Run");
            run_step.dependOn(&run_cmd.step);
            part += 1;
        }

        // test step
        const build_test = b.addTest(.{
            .root_source_file = b.path(b.fmt("src/{s}/solution.zig", .{dayString})),
            .target = target,
            .optimize = mode,
        });
        const run_test = b.addRunArtifact(build_test);
        const test_step = b.step(b.fmt("test_{s}", .{dayString}), "Run tests");
        test_step.dependOn(&run_test.step);
    }
}
