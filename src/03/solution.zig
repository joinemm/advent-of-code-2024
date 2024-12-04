const std = @import("std");

const puzzle_input = @embedFile("input.txt");
const sample_input = @embedFile("sample.txt");

// Me: mom can we import a regex library?
// Mom: no, we have regex at home
fn regex_at_home(alloc: std.mem.Allocator, find: []const u8, input: []const u8) !std.ArrayList([]u8) {
    var next_char: usize = 0;
    var number_mode = false;
    var matches = std.ArrayList([]u8).init(alloc);
    var match = std.ArrayList(u8).init(alloc);
    defer match.deinit();

    var i: usize = 0;
    while (i < input.len) {
        const ch = input[i];
        i += 1;

        if (find[next_char] == '$') {
            // number mode
            number_mode = true;
            if (std.ascii.isDigit(ch)) {
                try match.append(ch);
            } else {
                next_char += 1;
                number_mode = false;
            }
        } else {
            number_mode = false;
        }

        if (!number_mode) {
            // match ascii
            if (ch == find[next_char]) {
                try match.append(ch);
                next_char += 1;
            } else {
                // reset
                if (match.items.len != 0) {
                    i -= 1;
                    match.clearRetainingCapacity();
                    next_char = 0;
                }
            }
        }

        if (next_char == find.len) {
            // complete match, save and reset
            try matches.append(try alloc.dupe(u8, match.items));
            match.clearRetainingCapacity();
            next_char = 0;
        }
    }

    return matches;
}

// O(n)
pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var result: u32 = 0;

    const found = try regex_at_home(alloc, "mul($,$)", input);
    defer found.deinit();

    for (found.items) |instruction| {
        var numbers = std.mem.tokenizeScalar(u8, instruction[4 .. instruction.len - 1], ',');
        const n1 = try std.fmt.parseInt(u32, numbers.next().?, 10);
        const n2 = try std.fmt.parseInt(u32, numbers.next().?, 10);
        result += n1 * n2;
        alloc.free(instruction);
    }
    return result;
}

// O(n)
pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var result: u32 = 0;

    var it_do = std.mem.tokenizeSequence(u8, input, "do()");
    while (it_do.next()) |doer| {
        const where_dont = std.mem.indexOf(u8, doer, "don't()") orelse doer.len;
        const matches = try regex_at_home(alloc, "mul($,$)", doer[0..where_dont]);
        defer matches.deinit();

        for (matches.items) |instruction| {
            var numbers = std.mem.tokenizeScalar(u8, instruction[4 .. instruction.len - 1], ',');
            const n1 = try std.fmt.parseInt(u32, numbers.next().?, 10);
            const n2 = try std.fmt.parseInt(u32, numbers.next().?, 10);
            result += n1 * n2;
            alloc.free(instruction);
        }
    }

    return result;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    std.debug.print("Part 1: {any}\n", .{part_one(gpa.allocator(), puzzle_input)});
    std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), puzzle_input)});
}

test "part1.sample" {
    try std.testing.expectEqual(
        @as(u32, 161),
        part_one(std.testing.allocator, sample_input),
    );
}
test "part1.puzzle" {
    try std.testing.expectEqual(
        @as(u32, 182780583),
        part_one(std.testing.allocator, puzzle_input),
    );
}
test "part2.sample" {
    try std.testing.expectEqual(
        @as(u32, 48),
        part_two(std.testing.allocator, sample_input),
    );
}
test "part2.puzzle" {
    try std.testing.expectEqual(
        @as(u32, 90772405),
        part_two(std.testing.allocator, puzzle_input),
    );
}
