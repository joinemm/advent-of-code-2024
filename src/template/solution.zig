const std = @import("std");

const puzzle_input = @embedFile("input.txt");
const sample_input = @embedFile("sample.txt");

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    _ = alloc;
    _ = input;
    return 0;
}

pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u32 {
    _ = alloc;
    _ = input;
    return 0;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    std.debug.print("Part 1: {any}\n", .{part_one(gpa.allocator(), sample_input)});
    // std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), puzzle_input)});
}

test "part1.sample" {
    try std.testing.expectEqual(
        @as(u32, 0),
        part_one(std.testing.allocator, sample_input),
    );
}
// test "part1.puzzle" {
//     try std.testing.expectEqual(
//         @as(u32, 0),
//         part_one(std.testing.allocator, puzzle_input),
//     );
// }
// test "part2.sample" {
//     try std.testing.expectEqual(
//         @as(u32, 0),
//         part_two(std.testing.allocator, sample_input),
//     );
// }
// test "part2.puzzle" {
//     try std.testing.expectEqual(
//         @as(u32, 0),
//         part_two(std.testing.allocator, puzzle_input),
//     );
// }
