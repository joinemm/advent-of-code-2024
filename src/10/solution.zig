const std = @import("std");

pub const puzzle_input = @embedFile("input.txt");
pub const sample_input = @embedFile("sample.txt");

const Vec2 = [2]i8;

pub fn vec_eql(a: Vec2, b: Vec2) bool {
    return a[0] == b[0] and a[1] == b[1];
}
pub fn vec_add(a: Vec2, b: Vec2) Vec2 {
    return .{ a[0] + b[0], a[1] + b[1] };
}

pub fn vec_bounds(a: Vec2, x: usize, y: usize) bool {
    return a[1] >= 0 and a[1] < y and a[0] >= 0 and a[0] < x;
}

const directions: [4]Vec2 = .{
    .{ 1, 0 },
    .{ -1, 0 },
    .{ 0, 1 },
    .{ 0, -1 },
};

pub fn pathfind(map: [][]const u8, start: Vec2, finish: Vec2, value: u8) u32 {
    var trails: u32 = 0;
    for (directions) |dir| {
        const position = vec_add(start, dir);
        if (vec_bounds(position, map[0].len, map.len)) {
            const this_value = map[@intCast(position[1])][@intCast(position[0])];
            const is_next = this_value > value and this_value - value == 1;
            if (is_next) {
                if (vec_eql(position, finish)) {
                    trails += 1;
                } else {
                    trails += pathfind(map, position, finish, this_value);
                }
            }
        }
    }
    return trails;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8, rating: bool) !u32 {
    var total: u32 = 0;

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    var collector = std.ArrayList([]u8).init(arena.allocator());
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |row| try collector.append(try collector.allocator.dupe(u8, row));

    var map = try collector.toOwnedSlice();

    var zeros = std.ArrayList(Vec2).init(alloc);
    defer zeros.deinit();

    var nines = std.ArrayList(Vec2).init(alloc);
    defer nines.deinit();

    var y: i8 = 0;
    while (y < map.len) : (y += 1) {
        var x: i8 = 0;
        while (x < map[@intCast(y)].len) : (x += 1) {
            const ch = map[@intCast(y)][@intCast(x)];
            const n = try std.fmt.parseInt(u8, &.{ch}, 10);
            map[@intCast(y)][@intCast(x)] = n;

            if (n == 0) {
                try zeros.append(.{ x, y });
            } else if (n == 9) {
                try nines.append(.{ x, y });
            }
        }
    }

    for (zeros.items) |start| {
        for (nines.items) |finish| {
            const trails = pathfind(map, start, finish, 0);
            if (rating) {
                total += trails;
            } else if (trails > 0) {
                total += 1;
            }
        }
    }

    return total;
}

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    return try solve(alloc, input, false);
}

pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u32 {
    return try solve(alloc, input, true);
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    std.debug.print("Part 1: {any}\n", .{part_one(gpa.allocator(), puzzle_input)});
    std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), puzzle_input)});
}

// imported by unit tests
pub const answers: [4]u32 = .{ 36, 574, 81, 1238 };
