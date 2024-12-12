const std = @import("std");

pub const puzzle_input = @embedFile("input.txt");
pub const sample_input = @embedFile("sample.txt");

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
    // std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), sample_input)});
}

// imported by unit tests
pub const answers: [4]u32 = .{ 0, 0, 0, 0 };
