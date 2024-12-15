const std = @import("std");

pub const puzzle_input = @embedFile("input.txt");
pub const sample_input = @embedFile("sample.txt");

const Pair = struct {
    x: i64,
    y: i64,

    pub fn parse(row: []const u8, offset: usize) !Pair {
        var it = std.mem.tokenizeScalar(u8, row[offset..], ',');
        const x = try std.fmt.parseInt(i64, it.next().?[3..], 10);
        const y = try std.fmt.parseInt(i64, it.next().?[3..], 10);
        return .{ .x = x, .y = y };
    }
};

pub fn solve(input: []const u8, c: i64) !i64 {
    var total: i64 = 0;
    var machines = std.mem.tokenizeSequence(u8, input, "\n\n");
    while (machines.next()) |machine| {
        var rows = std.mem.tokenizeScalar(u8, machine, '\n');
        const a = try Pair.parse(rows.next().?, 9);
        const b = try Pair.parse(rows.next().?, 9);
        const p = try Pair.parse(rows.next().?, 6);

        // B presses
        const n_b_num = (p.y + c) * a.x - (p.x + c) * a.y;
        const n_b_det = a.x * b.y - a.y * b.x;
        if (@mod(n_b_num, n_b_det) != 0) continue;
        const n_b = @divExact(n_b_num, n_b_det);

        // A presses
        const n_a_num = p.x + c - n_b * b.x;
        if (@mod(n_a_num, a.x) != 0) continue;
        const n_a = @divExact(n_a_num, a.x);

        const tokens = n_a * 3 + n_b;
        total += tokens;
    }

    return total;
}

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !i64 {
    _ = alloc;
    return try solve(input, 0);
}

pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !i64 {
    _ = alloc;
    return try solve(input, 10000000000000);
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    std.debug.print("Part 1: {any}\n", .{part_one(gpa.allocator(), puzzle_input)});
    std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), puzzle_input)});
}

// imported by unit tests
pub const answers: [4]i64 = .{ 480, 35255, 875318608908, 87582154060429 };
