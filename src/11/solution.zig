const std = @import("std");

pub const puzzle_input = @embedFile("input.txt");
pub const sample_input = @embedFile("sample.txt");

const StoneMap = std.AutoArrayHashMap(usize, usize);

fn add(stones: *StoneMap, key: u64, amount: usize) !void {
    const entry = try stones.getOrPut(key);
    if (entry.found_existing) {
        entry.value_ptr.* += amount;
    } else {
        entry.value_ptr.* = amount;
    }
}

fn blink(alloc: std.mem.Allocator, stones: *StoneMap) !StoneMap {
    var new_stones = std.AutoArrayHashMap(usize, usize).init(alloc);
    var it = stones.iterator();
    while (it.next()) |entry| {
        const stone = entry.key_ptr.*;
        const amount = entry.value_ptr.*;
        if (stone == 0) {
            try add(&new_stones, 1, amount);
        } else if ((std.math.log10_int(stone) + 1) % 2 == 0) {
            const d = std.math.log10_int(stone) + 1;
            const div = try std.math.powi(usize, 10, d - d / 2);
            const split: [2]usize = .{
                stone % div,
                stone / div,
            };
            for (split) |fragment| {
                try add(&new_stones, fragment, amount);
            }
        } else {
            try add(&new_stones, stone * 2024, amount);
        }
    }

    return new_stones;
}

fn solve(alloc: std.mem.Allocator, input: []const u8, blinks: usize) !usize {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    var stones = StoneMap.init(arena.allocator());

    // remove trailing newline before tokenizing
    var it = std.mem.tokenizeScalar(u8, input[0 .. input.len - 1], ' ');
    while (it.next()) |s| {
        try stones.put(try std.fmt.parseInt(usize, s, 10), 1);
    }

    for (0..blinks) |_| {
        stones = try blink(stones.allocator, &stones);
    }

    var total: usize = 0;
    for (stones.values()) |n| total += n;
    return total;
}

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !usize {
    return try solve(alloc, input, 25);
}

pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !usize {
    return try solve(alloc, input, 75);
}

fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    std.debug.print("Part 1: {any}\n", .{part_one(gpa.allocator(), puzzle_input)});
    std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), sample_input)});
}

// imported by unit tests
pub const answers: [4]usize = .{ 55312, 186203, 65601038650482, 221291560078593 };
