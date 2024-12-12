const std = @import("std");

pub const puzzle_input = @embedFile("input.txt");
pub const sample_input = @embedFile("sample.txt");

// O(n)
pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var total: u32 = 0;

    var left = std.ArrayList(i32).init(alloc);
    defer left.deinit();

    var right = std.ArrayList(i32).init(alloc);
    defer right.deinit();

    var rows = std.mem.tokenizeScalar(u8, input, '\n');
    while (rows.next()) |row| {
        var numbers = std.mem.tokenizeScalar(u8, row, ' ');
        const first = try std.fmt.parseInt(i32, numbers.next().?, 10);
        const second = try std.fmt.parseInt(i32, numbers.next().?, 10);

        try left.append(first);
        try right.append(second);
    }

    std.mem.sort(i32, left.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right.items, {}, comptime std.sort.asc(i32));

    var i: usize = 0;
    while (i < left.items.len) : (i += 1) {
        total += @abs(left.items[i] - right.items[i]);
    }

    return total;
}

// O(n)
pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var total: u32 = 0;

    var left = std.ArrayList(u32).init(alloc);
    defer left.deinit();

    var occurence = std.AutoHashMap(u32, u32).init(alloc);
    defer occurence.deinit();

    var rows = std.mem.tokenizeScalar(u8, input, '\n');
    while (rows.next()) |row| {
        var numbers = std.mem.tokenizeScalar(u8, row, ' ');
        const first = try std.fmt.parseInt(u32, numbers.next().?, 10);
        const second = try std.fmt.parseInt(u32, numbers.next().?, 10);

        try left.append(first);
        const v = try occurence.getOrPut(second);
        if (!v.found_existing) {
            v.value_ptr.* = 1;
        } else {
            v.value_ptr.* += 1;
        }
    }

    var i: usize = 0;
    while (i < left.items.len) : (i += 1) {
        const number = left.items[i];
        if (occurence.get(number)) |amount| {
            total += number * amount;
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
pub const answers: [4]u32 = .{ 11, 1319616, 31, 27267728 };
