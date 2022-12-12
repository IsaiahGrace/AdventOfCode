const std = @import("std");

const Point = struct {
    x: i32,
    y: i32,
};

const Rope = struct {
    head: Point,
    tail: Point,
};

const Direction = enum(u8) {
    U = 'U',
    D = 'D',
    L = 'L',
    R = 'R',
};

const Command = struct {
    dir: Direction,
    times: u32,
};

const PointSet = std.AutoHashMap(Point, void);

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u32 {
    const part1 = try solveP1(allocator, input);

    return [2]u32{ part1, 0 };
}

fn solveP1(allocator: std.mem.Allocator, input: []u8) !u32 {
    var visitedPoints = PointSet.init(allocator);
    defer visitedPoints.deinit();

    var rope = Rope{
        .head = Point{
            .x = 0,
            .y = 0,
        },
        .tail = Point{
            .x = 0,
            .y = 0,
        },
    };

    try visitedPoints.put(rope.tail, {});

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        const cmd = try getCommand(line);
        var i: u32 = 0;
        while (i < cmd.times) : (i += 1) {
            //std.log.info("({d},{d})---({d},{d})", .{ rope.head.x, rope.head.y, rope.tail.x, rope.tail.y });
            moveRope(&rope, cmd.dir);
            try visitedPoints.put(rope.tail, {});
        }
    }

    return @intCast(u32, visitedPoints.count());
}

fn moveRope(rope: *Rope, dir: Direction) void {
    const oldHead: Point = rope.head;
    switch (dir) {
        .U => rope.head.y += 1,
        .D => rope.head.y -= 1,
        .L => rope.head.x -= 1,
        .R => rope.head.x += 1,
    }
    const dx: i32 = rope.head.x - rope.tail.x;
    const dy: i32 = rope.head.y - rope.tail.y;
    if (dx > 1 or dx < -1 or dy > 1 or dy < -1) {
        rope.tail = oldHead;
    }
}

fn getCommand(line: []const u8) !Command {
    var tokens = std.mem.tokenize(u8, line, " ");
    var command: Command = undefined;
    command.dir = @intToEnum(Direction, tokens.next().?[0]);
    command.times = try std.fmt.parseUnsigned(u32, tokens.next().?, 10);
    return command;
}

test "PointSet" {
    const allocator = std.testing.allocator;

    var set = PointSet.init(allocator);
    defer set.deinit();

    var point = Point{
        .x = 20,
        .y = 3,
    };

    try set.put(point, {});
    try set.put(point, {});
    try std.testing.expectEqual(set.count(), 1);

    point.x = 1234;
    try set.put(point, {});
    try std.testing.expectEqual(set.count(), 2);
}
