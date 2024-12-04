const std = @import("std");

const puzzle_input = @embedFile("input/04.txt");
const sample_input = @embedFile("sample/04.txt");

fn scan_direction(find: []const u8, items: [][]const u8, y: i32, x: i32, yd: i32, xd: i32) bool {
    var next: i32 = 0;
    return while (next < find.len) {
        const row_index = y + yd * (next + 1);
        const col_index = x + xd * (next + 1);
        if (row_index < 0 or row_index > items.len - 1 or col_index < 0 or col_index > items[@intCast(row_index)].len - 1) {
            break false;
        }
        const ch = items[@intCast(row_index)][@intCast(col_index)];
        if (ch == find[@intCast(next)]) {
            next += 1;
        } else {
            break false;
        }
    } else true;
}

fn search_around(items: [][]const u8, y: i32, x: i32) u32 {
    var total: u32 = 0;
    var yd: i32 = if (y == 0) 0 else -1;
    while (yd < 2 and y + yd < items.len) : (yd += 1) {
        var xd: i32 = if (x == 0) 0 else -1;
        while (xd < 2 and x + xd < items[@intCast(y)].len) : (xd += 1) {
            if (yd == 0 and xd == 0) {
                continue;
            }
            if (scan_direction("MAS", items, y, x, yd, xd)) {
                total += 1;
            }
        }
    }
    return total;
}

fn x_mas(items: [][]const u8, y: i32, x: i32) bool {
    return ((scan_direction("MAS", items, y - 2, x - 2, 1, 1) or scan_direction("MAS", items, y + 2, x + 2, -1, -1)) and
        (scan_direction("MAS", items, y - 2, x + 2, 1, -1) or scan_direction("MAS", items, y + 2, x - 2, -1, 1)));
}

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var total: u32 = 0;

    var rows = std.ArrayList([]const u8).init(alloc);
    defer rows.deinit();

    var it_rows = std.mem.tokenizeScalar(u8, input, '\n');
    while (it_rows.next()) |row| {
        try rows.append(row);
    }

    var y: i32 = 0;
    while (y < rows.items.len) : (y += 1) {
        var x: i32 = 0;
        while (x < rows.items[@intCast(y)].len) : (x += 1) {
            const ch = rows.items[@intCast(y)][@intCast(x)];
            if (ch == 'X') {
                total += search_around(rows.items, y, x);
            }
        }
    }
    return total;
}

pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var total: u32 = 0;

    var rows = std.ArrayList([]const u8).init(alloc);
    defer rows.deinit();

    var it_rows = std.mem.tokenizeScalar(u8, input, '\n');
    while (it_rows.next()) |row| {
        try rows.append(row);
    }

    var y: i32 = 1;
    while (y < rows.items.len - 1) : (y += 1) {
        var x: i32 = 1;
        while (x < rows.items[@intCast(y)].len - 1) : (x += 1) {
            const ch = rows.items[@intCast(y)][@intCast(x)];
            if (ch == 'A' and x_mas(rows.items, y, x)) {
                total += 1;
            }
        }
    }

    return total;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    std.debug.print("Part 1: {any}\n", .{part_one(gpa.allocator(), puzzle_input)});
    std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), puzzle_input)});
}

test "part1.sample" {
    try std.testing.expectEqual(
        @as(u32, 18),
        part_one(std.testing.allocator, sample_input),
    );
}
test "part1.puzzle" {
    try std.testing.expectEqual(
        @as(u32, 2406),
        part_one(std.testing.allocator, puzzle_input),
    );
}
test "part2.sample" {
    try std.testing.expectEqual(
        @as(u32, 9),
        part_two(std.testing.allocator, sample_input),
    );
}
test "part2.puzzle" {
    try std.testing.expectEqual(
        @as(u32, 1807),
        part_two(std.testing.allocator, puzzle_input),
    );
}
