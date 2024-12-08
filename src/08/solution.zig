const std = @import("std");

const puzzle_input = @embedFile("input.txt");
const sample_input = @embedFile("sample.txt");

const Vec2 = [2]i8;

pub fn vec_add(a: Vec2, b: Vec2) Vec2 {
    return .{ a[0] + b[0], a[1] + b[1] };
}

pub fn vec_sub(a: Vec2, b: Vec2) Vec2 {
    return .{ a[0] - b[0], a[1] - b[1] };
}

pub fn vec_bounds(a: Vec2, x: i8, y: i8) bool {
    return a[1] >= 0 and a[1] < y and a[0] >= 0 and a[0] < x;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8, harmonics: bool) !u32 {
    // arena allocator makes it easy to release all memory allocated by
    // the hashmap values (ArrayLists) without manually going through them
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    var collector = std.ArrayList([]const u8).init(arena.allocator());
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |row| {
        try collector.append(row);
    }

    const map = try collector.toOwnedSlice();
    var antennas = std.AutoArrayHashMap(u8, std.ArrayList(Vec2)).init(arena.allocator());
    var antinodes = std.AutoHashMap(Vec2, void).init(arena.allocator());

    var y: i8 = 0;
    var x: i8 = 0;
    while (y < map.len) {
        while (x < map[@intCast(y)].len) : (x += 1) {
            const ch = map[@intCast(y)][@intCast(x)];
            if (ch != '.') {
                var entry = try antennas.getOrPut(ch);
                if (!entry.found_existing) {
                    entry.value_ptr.* = std.ArrayList(Vec2).init(arena.allocator());
                }
                try entry.value_ptr.append(.{ x, y });
            }
        }
        y += 1;
        x = 0;
    }

    // O(n^2) where n = maximum number of antennae on the same frequency
    for (antennas.keys()) |key| {
        const towers = antennas.get(key).?.items;
        for (towers) |this| {
            for (towers) |other| {
                if (std.meta.eql(this, other)) continue;

                const offset = vec_sub(other, this);
                var antinode = vec_add(other, offset);

                if (harmonics) {
                    try antinodes.put(this, {});
                    while (vec_bounds(antinode, x, y)) {
                        try antinodes.put(antinode, {});
                        antinode = vec_add(antinode, offset);
                    }
                } else {
                    if (vec_bounds(antinode, x, y)) {
                        try antinodes.put(antinode, {});
                    }
                }
            }
        }
    }

    return antinodes.count();
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

test "part1.sample" {
    try std.testing.expectEqual(
        @as(u32, 14),
        part_one(std.testing.allocator, sample_input),
    );
}
test "part1.puzzle" {
    try std.testing.expectEqual(
        @as(u32, 371),
        part_one(std.testing.allocator, puzzle_input),
    );
}
test "part2.sample" {
    try std.testing.expectEqual(
        @as(u32, 34),
        part_two(std.testing.allocator, sample_input),
    );
}
test "part2.puzzle" {
    try std.testing.expectEqual(
        @as(u32, 1229),
        part_two(std.testing.allocator, puzzle_input),
    );
}
