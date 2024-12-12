const std = @import("std");
const solution = @import("solution");

pub fn run_test(
    comptime T: type,
    comptime f: fn (alloc: std.mem.Allocator, input: []const u8) anyerror!T,
    input: []const u8,
    eqls: T,
) !void {
    try std.testing.expectEqual(
        eqls,
        f(std.testing.allocator, input),
    );
}

test "part1.sample" {
    const answer = solution.answers[0];
    try run_test(@TypeOf(answer), solution.part_one, solution.sample_input, answer);
}

test "part1.puzzle" {
    const answer = solution.answers[1];
    try run_test(@TypeOf(answer), solution.part_one, solution.puzzle_input, answer);
}

test "part2.sample" {
    const answer = solution.answers[2];
    try run_test(@TypeOf(answer), solution.part_two, solution.sample_input, answer);
}

test "part2.puzzle" {
    const answer = solution.answers[3];
    try run_test(@TypeOf(answer), solution.part_two, solution.puzzle_input, answer);
}
