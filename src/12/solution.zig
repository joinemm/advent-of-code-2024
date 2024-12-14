const std = @import("std");

pub const puzzle_input = @embedFile("input.txt");
pub const sample_input = @embedFile("sample.txt");

const Vec2 = [2]i32;

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
    .{ 0, 1 },
    .{ -1, 0 },
    .{ 0, -1 },
};

const corner_directions: [4]Vec2 = .{
    .{ 1, 1 },
    .{ -1, 1 },
    .{ -1, -1 },
    .{ 1, -1 },
};

pub fn edge(map: [][]const u8, pos: Vec2, plant: u8, processed: *std.AutoHashMap(Vec2, void)) ![2]u32 {
    var additional_edges: u32 = 0;
    var additional_area: u32 = 0;
    for (directions) |dir| {
        const to = vec_add(pos, dir);
        if (vec_bounds(to, map[0].len, map.len)) {
            const the_plant = map[@intCast(to[1])][@intCast(to[0])];
            if (the_plant == plant) {
                const entry = try processed.getOrPut(to);
                if (entry.found_existing) {
                    continue;
                } else {
                    entry.value_ptr.* = {};
                }
                const edged = try edge(map, to, plant, processed);
                additional_edges += edged[0];
                additional_area += edged[1] + 1;
            } else {
                additional_edges += 1;
            }
        } else {
            additional_edges += 1;
        }
    }
    return .{ additional_edges, additional_area };
}

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var total: u32 = 0;

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    var collector = std.ArrayList([]u8).init(arena.allocator());
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |row| try collector.append(try collector.allocator.dupe(u8, row));

    const map = try collector.toOwnedSlice();

    var processed = std.AutoHashMap(Vec2, void).init(alloc);
    defer processed.deinit();

    var y: i32 = 0;
    while (y < map.len) : (y += 1) {
        var x: i32 = 0;
        while (x < map[@intCast(y)].len) : (x += 1) {
            const loc: Vec2 = .{ x, y };
            const entry = try processed.getOrPut(loc);
            if (entry.found_existing) continue;

            const plant = map[@intCast(y)][@intCast(x)];
            const plot = try edge(map, loc, plant, &processed);
            total += (plot[1] + 1) * plot[0];
        }
    }

    return total;
}

pub fn corner_detector(map: [][]const u8, pos: Vec2, plant: u8, processed: *std.AutoHashMap(Vec2, void), corners: *u32) !u32 {
    var area: u32 = 0;
    var neighbours: [4]bool = .{ false, false, false, false };
    for (directions, 0..) |dir, i| {
        const to = vec_add(pos, dir);
        if (vec_bounds(to, map[0].len, map.len)) {
            const the_plant = map[@intCast(to[1])][@intCast(to[0])];
            if (the_plant == plant) {
                neighbours[i] = true;
                const entry = try processed.getOrPut(to);
                if (entry.found_existing) {
                    continue;
                } else {
                    entry.value_ptr.* = {};
                }
                area += try corner_detector(map, to, plant, processed, corners) + 1;
            }
        }
    }
    for (corner_directions, 0..) |dir, i| {
        if (!neighbours[i] and !neighbours[(i + 1) % 4]) corners.* += 1;
        const to = vec_add(pos, dir);
        if (vec_bounds(to, map[0].len, map.len)) {
            if (map[@intCast(to[1])][@intCast(to[0])] == plant) continue;
        }
        if (neighbours[i] and neighbours[(i + 1) % 4]) corners.* += 1;
    }

    return area;
}

pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var total: u32 = 0;

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    var collector = std.ArrayList([]u8).init(arena.allocator());
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |row| try collector.append(try collector.allocator.dupe(u8, row));

    const map = try collector.toOwnedSlice();

    var processed = std.AutoHashMap(Vec2, void).init(alloc);
    defer processed.deinit();

    var y: i32 = 0;
    while (y < map.len) : (y += 1) {
        var x: i32 = 0;
        while (x < map[@intCast(y)].len) : (x += 1) {
            const loc: Vec2 = .{ x, y };
            const entry = try processed.getOrPut(loc);
            if (entry.found_existing) continue;

            var corners: u32 = 0;
            const plant = map[@intCast(y)][@intCast(x)];
            const area = try corner_detector(map, loc, plant, &processed, &corners) + 1;
            total += area * corners;
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
pub const answers: [4]u32 = .{ 1930, 1485656, 1206, 899196 };
