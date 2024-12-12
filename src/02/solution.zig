const std = @import("std");

pub const puzzle_input = @embedFile("input.txt");
pub const sample_input = @embedFile("sample.txt");

fn detect_unsafe_level(digits: []const u8) !?i32 {
    var trend: i32 = 0;
    var prev = digits[0];
    var i: i32 = 0;
    for (digits[1..]) |n| {
        const delta: i32 = @as(i32, n) - prev;
        if (@abs(delta) > 3 or delta == 0 or (delta < 0 and trend > 0) or (delta > 0 and trend < 0)) {
            return i;
        }
        trend = delta;
        prev = n;
        i += 1;
    }
    return null;
}

fn parse_digits(alloc: std.mem.Allocator, row: []const u8) !std.ArrayList(u8) {
    var digits = std.ArrayList(u8).init(alloc);
    var chars = std.mem.tokenizeScalar(u8, row, ' ');
    while (chars.next()) |ch| {
        try digits.append(try std.fmt.parseInt(u8, ch, 10));
    }
    return digits;
}

// O(n)
pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var total: u32 = 0;

    var rows = std.mem.tokenizeScalar(u8, input, '\n');
    while (rows.next()) |row| {
        const digits = try parse_digits(alloc, row);
        defer digits.deinit();

        if (try detect_unsafe_level(digits.items) == null) {
            total += 1;
        }
    }
    return total;
}

// O(n)
pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var total: u32 = 0;

    var rows = std.mem.tokenizeScalar(u8, input, '\n');
    while (rows.next()) |row| {
        const digits = try parse_digits(alloc, row);
        defer digits.deinit();

        if (try detect_unsafe_level(digits.items)) |where| {
            var index: usize = @intCast(if (where == 0) 0 else where - 1);
            while (index < digits.items.len and index < where + 2) : (index += 1) {
                var dampened_digits = try digits.clone();
                defer dampened_digits.deinit();
                _ = dampened_digits.orderedRemove(index);

                if (try detect_unsafe_level(dampened_digits.items) == null) {
                    total += 1;
                    break;
                }
            }
        } else {
            total += 1;
        }
    }
    return total;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    std.debug.print("Part 1: {any}\n", .{part_one(gpa.allocator(), puzzle_input)});
    std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), puzzle_input)});
}

// imported by unit tests
pub const answers: [4]u32 = .{ 2, 279, 4, 343 };
