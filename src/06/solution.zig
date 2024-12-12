const std = @import("std");

pub const puzzle_input = @embedFile("input.txt");
pub const sample_input = @embedFile("sample.txt");

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
    pub fn turn(self: *Guard, lab: *Lab) void {
        for (0..4) |_| {
            const front = add(self.location, self.facing);
            const tile = lab.get(front);
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
    allocator: std.mem.Allocator,
    guard: Guard,
    width: u16,
    height: u16,
    map: [][]Tile,

    pub fn init(alloc: std.mem.Allocator, input: []const u8) !Lab {
        var map_array = std.ArrayList([]Tile).init(alloc);
        var rows = std.mem.tokenizeScalar(u8, input, '\n');
        var guard: Guard = undefined;

        var y: i16 = 0;
        var x: i16 = 0;
        while (rows.next()) |row| : (y += 1) {
            x = 0;
            var row_tiles = std.ArrayList(Tile).init(alloc);
            for (row) |ch| {
                if (ch == '#') {
                    try row_tiles.append(Tile.wall);
                } else if (ch == '.') {
                    try row_tiles.append(Tile.air);
                } else {
                    try row_tiles.append(Tile.air);
                    const facing = switch (ch) {
                        '^' => Direction.north,
                        '>' => Direction.east,
                        'v' => Direction.south,
                        '<' => Direction.west,
                        else => unreachable,
                    };
                    const location: Coord = .{ .x = x, .y = y };
                    guard = Guard{ .location = location, .facing = facing };
                }
                x += 1;
            }
            try map_array.append(try row_tiles.toOwnedSlice());
        }

        const map = try map_array.toOwnedSlice();

        return Lab{
            .allocator = alloc,
            .guard = guard,
            .map = map,
            .width = @abs(x),
            .height = @abs(y),
        };
    }

    pub fn deinit(self: *Lab) void {
        var i: usize = 0;
        while (i < self.map.len) : (i += 1) {
            self.allocator.free(self.map[i]);
        }
        self.allocator.free(self.map);
    }

    pub fn bounds(self: Lab, coord: Coord) bool {
        return coord.x >= 0 and coord.x < self.width and coord.y >= 0 and coord.y < self.height;
    }

    pub fn get(self: Lab, coord: Coord) ?Tile {
        if (self.bounds(coord)) {
            return self.map[@intCast(coord.y)][@intCast(coord.x)];
        }
        return null;
    }

    pub fn replace(self: Lab, coord: Coord, value: Tile) !void {
        if (self.bounds(coord)) {
            self.map[@intCast(coord.y)][@intCast(coord.x)] = value;
        } else {
            return error.OutOfBounds;
        }
    }
};

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var locations = std.AutoHashMapUnmanaged(Coord, void){};
    defer locations.deinit(alloc);

    var lab = try Lab.init(alloc, input);
    defer lab.deinit();

    try locations.put(alloc, lab.guard.location, {});
    while (true) {
        lab.guard.turn(&lab);
        lab.guard.move();

        // keep adding locations as long as we are within bounds
        if (lab.bounds(lab.guard.location)) {
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
    defer lab.deinit();

    while (true) {
        if (lab.bounds(lab.guard.location)) {
            try locations.put(alloc, lab.guard.location, lab.guard.facing);
        } else {
            break;
        }

        lab.guard.turn(&lab);

        // moving happens only as last step
        defer lab.guard.move();

        const front = add(lab.guard.location, lab.guard.facing);
        if (locations.count() < 2 or barrels.get(front) != null) {
            continue;
        }

        // set an obstacle right in front of our current location and spawn
        // a ghost guard that continues our pathfinding with this new obstacle
        // until it goes out of bounds or ends up in a loop
        lab.replace(front, Tile.wall) catch continue;

        var ghost_guard = Guard{ .location = lab.guard.location, .facing = lab.guard.facing };
        var ghost_guard_locations = try locations.clone(alloc);
        defer ghost_guard_locations.deinit(alloc);

        const looping = while (true) {
            ghost_guard.turn(&lab);
            ghost_guard.move();

            // if we end up in the same location and facing the same
            // direction as before then we are in a loop
            const past = ghost_guard_locations.get(ghost_guard.location);
            if (past != null and ghost_guard.facing == past.?) {
                break true;
            }

            if (lab.bounds(ghost_guard.location)) {
                try ghost_guard_locations.put(alloc, ghost_guard.location, ghost_guard.facing);
            } else {
                break false;
            }
        };

        try barrels.put(alloc, front, looping);

        // remove our temporary obstacle
        try lab.replace(front, Tile.air);
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

// imported by unit tests
pub const answers: [4]u32 = .{ 41, 4559, 6, 1604 };
