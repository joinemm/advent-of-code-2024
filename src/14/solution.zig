const std = @import("std");

pub const puzzle_input = @embedFile("input.txt");
pub const sample_input = @embedFile("sample.txt");

const Vec2 = [2]i32;

const Robot = struct {
    position: Vec2,
    velocity: Vec2,

    pub fn move(self: *Robot, space: Vec2) void {
        self.position = .{
            @mod((self.position[0] + self.velocity[0]), space[0]),
            @mod((self.position[1] + self.velocity[1]), space[1]),
        };
    }
};

/// parses a comma separated string like p=x,y into a vector of x and y
fn parse_vec(s: []const u8) !Vec2 {
    var p = std.mem.tokenizeScalar(u8, s[2..], ',');
    return .{
        try std.fmt.parseInt(i32, p.next().?, 10),
        try std.fmt.parseInt(i32, p.next().?, 10),
    };
}

/// sorts robots based on their x and y position, first by y, then by x if they are on the same row
fn robotsorter(_: void, a: Robot, b: Robot) bool {
    return a.position[1] < b.position[1] or (a.position[1] == b.position[1] and a.position[0] < b.position[0]);
}

/// parse input into slice of Robots
fn parse(alloc: std.mem.Allocator, input: []const u8) ![]Robot {
    var robots = std.ArrayList(Robot).init(alloc);
    defer robots.deinit();
    var rows = std.mem.tokenizeScalar(u8, input, '\n');
    while (rows.next()) |row| {
        var parts = std.mem.tokenizeScalar(u8, row, ' ');
        const robot: Robot = .{
            .position = try parse_vec(parts.next().?),
            .velocity = try parse_vec(parts.next().?),
        };
        try robots.append(robot);
    }

    return try robots.toOwnedSlice();
}

/// Print the space
fn print(space: Vec2, robots: []Robot) void {
    var y: i32 = 0;
    while (y < space[1]) : (y += 1) {
        var x: i32 = 0;
        while (x < space[0]) : (x += 1) {
            const pos: Vec2 = .{ x, y };
            var found = false;
            for (robots) |robot| {
                if (pos[0] == robot.position[0] and pos[1] == robot.position[1]) {
                    std.debug.print("#", .{});
                    found = true;
                    break;
                }
            }
            if (!found) {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}

pub fn part_one(alloc: std.mem.Allocator, input: []const u8) !u32 {
    const space: Vec2 = if (std.mem.eql(u8, input, sample_input)) .{ 11, 7 } else .{ 101, 103 };

    var robots = try parse(alloc, input);
    defer alloc.free(robots);

    for (0..100) |_| {
        var j: usize = 0;
        while (j < robots.len) : (j += 1) {
            robots[j].move(space);
        }
    }

    const half_x = @divExact(space[0] - 1, 2);
    const half_y = @divExact(space[1] - 1, 2);

    const quadrants: [4][2]Vec2 = .{
        .{ .{ 0, 0 }, .{ half_x - 1, half_y - 1 } },
        .{ .{ half_x + 1, 0 }, .{ space[0] - 1, half_y - 1 } },
        .{ .{ 0, half_y + 1 }, .{ half_x - 1, space[1] - 1 } },
        .{ .{ half_x + 1, half_y + 1 }, .{ space[0] - 1, space[1] - 1 } },
    };

    var total: u32 = 1;
    for (quadrants) |quad| {
        var robotcount: u32 = 0;
        for (robots) |robot| {
            if ((robot.position[0] >= quad[0][0] and robot.position[0] <= quad[1][0]) and (robot.position[1] >= quad[0][1] and robot.position[1] <= quad[1][1])) {
                robotcount += 1;
            }
        }
        total *= robotcount;
    }

    return total;
}

pub fn part_two(alloc: std.mem.Allocator, input: []const u8) !u32 {
    const space: Vec2 = if (std.mem.eql(u8, input, sample_input)) .{ 11, 7 } else .{ 101, 103 };

    var robots = try parse(alloc, input);
    defer alloc.free(robots);

    for (1..10404) |second| {
        var j: usize = 0;
        while (j < robots.len) : (j += 1) {
            robots[j].move(space);
        }

        std.mem.sort(Robot, robots, {}, robotsorter);

        var in_row: usize = 0;
        var prev_robot: Robot = robots[0];
        for (robots[1..]) |robot| {
            if (robot.position[1] == prev_robot.position[1] and robot.position[0] - prev_robot.position[0] == 1) {
                in_row += 1;
                if (in_row > 8) {
                    print(space, robots);
                    return @intCast(second);
                }
            } else {
                in_row = 0;
            }
            prev_robot = robot;
        }
    }

    return 0;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    std.debug.print("Part 1: {any}\n", .{part_one(gpa.allocator(), puzzle_input)});
    std.debug.print("Part 2: {any}\n", .{part_two(gpa.allocator(), puzzle_input)});
}

// imported by unit tests
pub const answers: [4]u32 = .{ 12, 224438715, 0, 7603 };
