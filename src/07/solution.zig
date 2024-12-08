const std = @import("std");

const puzzle_input = @embedFile("input.txt");
const sample_input = @embedFile("sample.txt");

const Operator = enum { add, multiply, concat };

const Context = struct {
    nums: []const u64,
    final: u64,
    operators: []const Operator,
};

pub fn descend(ctx: Context, i: usize, sum: u64) ?u64 {
    if (sum > ctx.final) return null;

    if (i >= ctx.nums.len) {
        if (sum == ctx.final) return sum;
        return null;
    }

    for (ctx.operators) |op| {
        const next_sum = switch (op) {
            Operator.add => sum + ctx.nums[i],
            Operator.multiply => sum * ctx.nums[i],
            Operator.concat => sum * std.math.pow(u64, 10, std.math.log10_int(ctx.nums[i]) + 1) + ctx.nums[i],
        };

        if (descend(ctx, i + 1, next_sum)) |value| return value;
    }

    return null;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8, with_ops: []const Operator) !u64 {
    var result: u64 = 0;

    var rows = std.mem.tokenizeScalar(u8, input, '\n');
    while (rows.next()) |row| {
        var elems = std.mem.tokenizeScalar(u8, row, ' ');
        const value_str = elems.next().?;
        const final = try std.fmt.parseInt(u64, value_str[0 .. value_str.len - 1], 10);

        var collector = std.ArrayList(u64).init(alloc);
        while (elems.next()) |num| try collector.append(try std.fmt.parseInt(u64, num, 10));
        const nums = try collector.toOwnedSlice();
        defer alloc.free(nums);
        const ctx: Context = .{ .nums = nums, .final = final, .operators = with_ops };

        if (descend(ctx, 1, ctx.nums[0])) |value| result += value;
    }
    return result;
}

// O(n*2^m) where n = rows; m = amount of numbers within one row
pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u64 {
    return try solve(alloc, input, &.{ Operator.add, Operator.multiply });
}

// O(n*3^m) where n = rows; m = amount of numbers within one row
pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u64 {
    return try solve(alloc, input, &.{ Operator.add, Operator.multiply, Operator.concat });
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    std.debug.print("Part 1: {any}\n", .{part_one(gpa.allocator(), puzzle_input)});
    std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), puzzle_input)});
}

test "part1.sample" {
    try std.testing.expectEqual(
        @as(u64, 3749),
        part_one(std.testing.allocator, sample_input),
    );
}
test "part1.puzzle" {
    try std.testing.expectEqual(
        @as(u64, 1260333054159),
        part_one(std.testing.allocator, puzzle_input),
    );
}
test "part2.sample" {
    try std.testing.expectEqual(
        @as(u64, 11387),
        part_two(std.testing.allocator, sample_input),
    );
}
test "part2.puzzle" {
    try std.testing.expectEqual(
        @as(u64, 162042343638683),
        part_two(std.testing.allocator, puzzle_input),
    );
}
