const std = @import("std");

const puzzle_input = @embedFile("input.txt");
const sample_input = @embedFile("sample.txt");

const Tile = enum { air, wall };

const Direction = enum {
    north,
    east,
    south,
    west,
};

const Coord = struct {
    x: i16,
    y: i16,

    pub fn eql(self: Coord, b: Coord) bool {
        return (self.x == b.x and self.y == b.y);
    }
};

pub fn add(coord: Coord, dir: Direction) Coord {
    return switch (dir) {
        .north => .{ .x = coord.x, .y = coord.y - 1 },
        .east => .{ .x = coord.x + 1, .y = coord.y },
        .south => .{ .x = coord.x, .y = coord.y + 1 },
        .west => .{ .x = coord.x - 1, .y = coord.y },
    };
}

pub fn rotate(self: Direction) Direction {
    return switch (self) {
        Direction.north => Direction.east,
        Direction.east => Direction.south,
        Direction.south => Direction.west,
        Direction.west => Direction.north,
    };
}

const Guard = struct {
    location: Coord,
    facing: Direction,

    /// turns 90 degrees clockwise as many times as it takes to not face a wall
    pub fn turn(self: *Guard, map: *std.HashMapUnmanaged(Coord, Tile, std.hash_map.AutoContext(Coord), 80)) void {
        for (0..4) |_| {
            const front = add(self.location, self.facing);
            const tile = map.get(front);
            if (tile != null and tile.? == Tile.wall) {
                self.facing = rotate(self.facing);
            } else {
                return;
            }
        }
        unreachable;
    }

    /// moves one step towards direction faced
    pub fn move(self: *Guard) void {
        self.location = add(self.location, self.facing);
    }
};

const Lab = struct {
    guard: Guard,
    width: u16,
    height: u16,
    map: std.HashMapUnmanaged(Coord, Tile, std.hash_map.AutoContext(Coord), 80),

    pub fn init(alloc: std.mem.Allocator, input: []const u8) !Lab {
        var map = std.AutoHashMapUnmanaged(Coord, Tile){};
        var rows = std.mem.tokenizeScalar(u8, input, '\n');
        var guard: Guard = undefined;

        var y: i16 = 0;
        var x: i16 = 0;
        while (rows.next()) |row| : (y += 1) {
            x = 0;
            for (row) |ch| {
                const location: Coord = .{ .x = x, .y = y };
                if (ch == '#') {
                    try map.put(alloc, location, Tile.wall);
                } else if (ch == '.') {
                    try map.put(alloc, location, Tile.air);
                } else {
                    const facing = switch (ch) {
                        '^' => Direction.north,
                        '>' => Direction.east,
                        'v' => Direction.south,
                        '<' => Direction.west,
                        else => unreachable,
                    };
                    guard = Guard{ .location = location, .facing = facing };
                }
                x += 1;
            }
        }

        return Lab{
            .guard = guard,
            .map = map,
            .width = @abs(x),
            .height = @abs(y),
        };
    }

    pub fn bounds(self: Lab, guard: Guard) bool {
        return guard.location.x >= 0 and guard.location.x < self.width and guard.location.y >= 0 and guard.location.y < self.height;
    }

    pub fn deinit(self: *Lab, alloc: std.mem.Allocator) void {
        self.map.deinit(alloc);
    }
};

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var locations = std.AutoHashMapUnmanaged(Coord, void){};
    defer locations.deinit(alloc);

    var lab = try Lab.init(alloc, input);
    defer lab.deinit(alloc);

    try locations.put(alloc, lab.guard.location, {});
    while (true) {
        lab.guard.turn(&lab.map);
        lab.guard.move();

        // keep adding locations as long as we are within bounds
        if (lab.bounds(lab.guard)) {
            try locations.put(alloc, lab.guard.location, {});
        } else {
            break;
        }
    }
    return locations.count();
}

pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var locations = std.AutoHashMapUnmanaged(Coord, Direction){};
    defer locations.deinit(alloc);

    var barrels = std.AutoArrayHashMapUnmanaged(Coord, bool){};
    defer barrels.deinit(alloc);

    var lab = try Lab.init(alloc, input);
    defer lab.deinit(alloc);

    while (true) {
        if (lab.bounds(lab.guard)) {
            try locations.put(alloc, lab.guard.location, lab.guard.facing);
        } else {
            break;
        }

        lab.guard.turn(&lab.map);

        // moving happens only as last step
        defer lab.guard.move();

        const front = add(lab.guard.location, lab.guard.facing);
        if (barrels.get(front) != null or locations.count() < 2) {
            continue;
        }

        // set an obstacle right in front of our current location and spawn
        // a ghost guard that continues our pathfinding with this new obstacle
        // until it goes out of bounds or ends up in a loop
        try lab.map.put(alloc, front, Tile.wall);

        var ghost_guard = Guard{ .location = lab.guard.location, .facing = lab.guard.facing };
        var ghost_guard_locations = try locations.clone(alloc);
        defer ghost_guard_locations.deinit(alloc);

        const looping = while (true) {
            ghost_guard.turn(&lab.map);
            ghost_guard.move();

            // if we end up in the same location and facing the same
            // direction as before then we are in a loop
            const past = ghost_guard_locations.get(ghost_guard.location);
            if (past != null and ghost_guard.facing == past.?) {
                break true;
            }

            if (lab.bounds(ghost_guard)) {
                try ghost_guard_locations.put(alloc, ghost_guard.location, ghost_guard.facing);
            } else {
                break false;
            }
        };

        try barrels.put(alloc, front, looping);

        // remove our temporary obstacle
        try lab.map.put(alloc, front, Tile.air);
    }

    // count how many barrels resulted in a loop
    var total: u32 = 0;
    for (barrels.values()) |v| {
        if (v) total += 1;
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
        @as(u32, 41),
        part_one(std.testing.allocator, sample_input),
    );
}
test "part1.puzzle" {
    try std.testing.expectEqual(
        @as(u32, 4559),
        part_one(std.testing.allocator, puzzle_input),
    );
}
test "part2.sample" {
    try std.testing.expectEqual(
        @as(u32, 6),
        part_two(std.testing.allocator, sample_input),
    );
}
test "part2.puzzle" {
    try std.testing.expectEqual(
        @as(u32, 1604),
        part_two(std.testing.allocator, puzzle_input),
    );
}
