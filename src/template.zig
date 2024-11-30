const std = @import("std");

const puzzle_input = @embedFile("input/00.txt");
const sample_input = @embedFile("sample/00.txt");

pub fn part_one(input: []const u8) !u32 {
    _ = input;
    return 0;
}

pub fn part_two(input: []const u8) !u32 {
    _ = input;
    return 0;
}

pub fn main() void {
    std.debug.print("{any}", .{part_one(sample_input)});
}

test "Part 1 example" {
    try std.testing.expectEqual(part_one(sample_input), @as(u32, 0));
}
test "Part 1 puzzle" {
    try std.testing.expectEqual(part_one(puzzle_input), @as(u32, 0));
}
test "Part 2 example" {
    try std.testing.expectEqual(part_two(sample_input), @as(u32, 0));
}
test "Part 2 puzzle" {
    try std.testing.expectEqual(part_two(puzzle_input), @as(u32, 0));
}
