const std = @import("std");

pub const puzzle_input = @embedFile("input.txt");
pub const sample_input = @embedFile("sample.txt");

const Parser = struct {
    rules: std.HashMap(u8, std.ArrayList(u8), std.hash_map.AutoContext(u8), 80),
    updates: std.mem.TokenIterator(u8, std.mem.DelimiterType.scalar),

    pub fn init(alloc: std.mem.Allocator, input: []const u8) !Parser {
        var parts = std.mem.tokenizeSequence(u8, input, "\n\n");
        var rules = std.mem.tokenizeScalar(u8, parts.next().?, '\n');
        const updates = std.mem.tokenizeScalar(u8, parts.next().?, '\n');

        var rule_map = std.AutoHashMap(u8, std.ArrayList(u8)).init(alloc);
        while (rules.next()) |rule| {
            var nums = std.mem.tokenizeScalar(u8, rule, '|');
            const before = try std.fmt.parseInt(u8, nums.next().?, 10);
            const after = try std.fmt.parseInt(u8, nums.next().?, 10);

            const entry = try rule_map.getOrPut(before);
            if (!entry.found_existing) {
                entry.value_ptr.* = std.ArrayList(u8).init(alloc);
            }
            try entry.value_ptr.*.append(after);
        }

        return Parser{
            .rules = rule_map,
            .updates = updates,
        };
    }
};

fn sorter(context: std.HashMap(u8, std.ArrayList(u8), std.hash_map.AutoContext(u8), 80), a: u8, b: u8) bool {
    if (context.get(a)) |comes_before| {
        return for (comes_before.items) |x| {
            if (x == b) {
                break true;
            }
        } else false;
    }
    return false;
}

fn take_middle(slice: []const u8) u32 {
    const middle_index: usize = (slice.len - 1) / 2;
    return slice[middle_index];
}

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var total: u32 = 0;

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    var parser = try Parser.init(arena.allocator(), input);

    while (parser.updates.next()) |update| {
        var seen_before = std.ArrayList(u8).init(alloc);
        defer seen_before.deinit();

        var nums = std.mem.tokenizeScalar(u8, update, ',');
        const is_correct = while (nums.next()) |ch| {
            const n = try std.fmt.parseInt(u8, ch, 10);
            if (parser.rules.get(n)) |comes_before| {
                const breaks_rules = for (comes_before.items) |x| {
                    if (std.mem.indexOfScalar(u8, seen_before.items, x) != null) {
                        break true;
                    }
                } else false;

                if (breaks_rules) {
                    break false;
                }
            }
            try seen_before.append(n);
        } else true;

        if (is_correct) {
            total += take_middle(seen_before.items);
        }
    }
    return total;
}

pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var total: u32 = 0;

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    var parser = try Parser.init(arena.allocator(), input);

    while (parser.updates.next()) |update| {
        var nums = std.ArrayList(u8).init(alloc);
        defer nums.deinit();

        var chs = std.mem.tokenizeScalar(u8, update, ',');
        while (chs.next()) |ch| try nums.append(try std.fmt.parseInt(u8, ch, 10));

        const slice = try nums.toOwnedSlice();
        defer alloc.free(slice);

        const slice_sorted = try alloc.dupe(u8, slice);
        defer alloc.free(slice_sorted);

        std.mem.sort(u8, slice_sorted, parser.rules, sorter);
        if (!std.mem.eql(u8, slice, slice_sorted)) {
            total += take_middle(slice_sorted);
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
pub const answers: [4]u32 = .{ 143, 6951, 123, 4121 };
