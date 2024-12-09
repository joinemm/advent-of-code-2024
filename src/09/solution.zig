const std = @import("std");

const puzzle_input = @embedFile("input.txt");
const sample_input = @embedFile("sample.txt");

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !usize {
    var checksum: usize = 0;
    var blocks = std.ArrayList(usize).init(alloc);
    // id 0 is reserved for free space
    var id: usize = 1;
    for (input[0 .. input.len - 1], 0..) |ch, i| {
        const digit = try std.fmt.parseInt(u8, &[_]u8{ch}, 10);
        if (i % 2 == 0) {
            for (0..digit) |_| {
                try blocks.append(id);
            }
            id += 1;
        } else {
            for (0..digit) |_| {
                try blocks.append(0);
            }
        }
    }
    var filesystem = try blocks.toOwnedSlice();
    defer alloc.free(filesystem);

    var a: usize = 0;
    var b: usize = filesystem.len - 1;
    outer: while (b > a) {
        if (filesystem[a] == 0) {
            while (filesystem[b] == 0) {
                b -= 1;
                if (b <= a) {
                    break :outer;
                }
            }
            filesystem[a] = filesystem[b];
            filesystem[b] = 0;
        }
        a += 1;
    }

    for (filesystem, 0..) |block, i| {
        if (block != 0) {
            checksum += (block - 1) * i;
        }
    }
    return checksum;
}

pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !usize {
    var checksum: usize = 0;
    var blocks = std.ArrayList(usize).init(alloc);
    // id 0 is reserved for free space
    var id: usize = 1;
    for (input[0 .. input.len - 1], 0..) |ch, i| {
        const digit = try std.fmt.parseInt(u8, &[_]u8{ch}, 10);
        if (i % 2 == 0) {
            for (0..digit) |_| {
                try blocks.append(id);
            }
            id += 1;
        } else {
            for (0..digit) |_| {
                try blocks.append(0);
            }
        }
    }
    var filesystem = try blocks.toOwnedSlice();
    defer alloc.free(filesystem);

    var b: usize = filesystem.len - 1;
    var moved = std.AutoHashMap(usize, void).init(alloc);
    while (b > 0) {
        const blockid = filesystem[b];
        if (moved.get(blockid) != null) {
            b -= 1;
            continue;
        }
        if (blockid == 0) {
            b -= 1;
            continue;
        }
        var ln: usize = 0;
        while (b > 0 and blockid == filesystem[b]) {
            ln += 1;
            b -= 1;
        }
        var a: usize = 0;
        var free_ln: usize = 0;
        while (a < b and free_ln < ln) {
            free_ln = 0;
            while (a <= b and filesystem[a] != 0) {
                a += 1;
            }
            while (a <= b and filesystem[a] == 0) {
                free_ln += 1;
                a += 1;
            }
            if (free_ln >= ln) {
                for (0..ln) |x| {
                    filesystem[a - free_ln + x] = blockid;
                    filesystem[b + 1 + x] = 0;
                }
                try moved.put(blockid, {});
                break;
            }
        }
    }

    for (filesystem, 0..) |block, i| {
        if (block != 0) {
            checksum += (block - 1) * i;
        }
    }
    return checksum;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    std.debug.print("Part 1: {any}\n", .{part_one(gpa.allocator(), puzzle_input)});
    std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), puzzle_input)});
}

test "part1.sample" {
    try std.testing.expectEqual(
        @as(usize, 1928),
        part_one(std.testing.allocator, sample_input),
    );
}
test "part1.puzzle" {
    try std.testing.expectEqual(
        @as(usize, 6430446922192),
        part_one(std.testing.allocator, puzzle_input),
    );
}
test "part2.sample" {
    try std.testing.expectEqual(
        @as(usize, 2858),
        part_two(std.testing.allocator, sample_input),
    );
}
test "part2.puzzle" {
    try std.testing.expectEqual(
        @as(usize, 6460170593016),
        part_two(std.testing.allocator, puzzle_input),
    );
}
