const std = @import("std");

const Point = struct {
    x: i32,
    y: i32,
};

const Rope = struct {
    head: Point,
    tail: []Point,
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

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    const part1 = try solveP1(allocator, input);
    const part2 = try solveP2(allocator, input);

    return [2]u64{ part1, part2 };
}

fn solveP1(allocator: std.mem.Allocator, input: []u8) !u32 {
    var visitedPoints = PointSet.init(allocator);
    defer visitedPoints.deinit();

    var rope = Rope{
        .head = Point{
            .x = 0,
            .y = 0,
        },
        .tail = try allocator.alloc(Point, 1),
    };
    defer allocator.free(rope.tail);

    for (rope.tail) |*tail| {
        tail.* = Point{ .x = 0, .y = 0 };
    }

    try visitedPoints.put(rope.tail[0], {});

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        const cmd = try getCommand(line);
        var i: u32 = 0;
        while (i < cmd.times) : (i += 1) {
            //std.log.info("({d},{d})---({d},{d})", .{ rope.head.x, rope.head.y, rope.tail[0].x, rope.tail[0].y });
            moveRope(&rope, cmd.dir);
            try visitedPoints.put(rope.tail[0], {});
        }
    }

    return @intCast(u32, visitedPoints.count());
}

fn solveP2(allocator: std.mem.Allocator, input: []u8) !u32 {
    var visitedPoints = PointSet.init(allocator);
    defer visitedPoints.deinit();

    var rope = Rope{
        .head = Point{
            .x = 0,
            .y = 0,
        },
        .tail = try allocator.alloc(Point, 9),
    };
    defer allocator.free(rope.tail);

    for (rope.tail) |*tail| {
        tail.* = Point{ .x = 0, .y = 0 };
    }

    try visitedPoints.put(rope.tail[8], {});

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        const cmd = try getCommand(line);
        var i: u32 = 0;
        while (i < cmd.times) : (i += 1) {
            // std.log.info("({d},{d})--({d},{d})-({d},{d})-({d},{d})-({d},{d})-({d},{d})-({d},{d})-({d},{d})-({d},{d})-({d},{d})", .{
            //     rope.head.x,    rope.head.y,
            //     rope.tail[0].x, rope.tail[0].y,
            //     rope.tail[1].x, rope.tail[1].y,
            //     rope.tail[2].x, rope.tail[2].y,
            //     rope.tail[3].x, rope.tail[3].y,
            //     rope.tail[4].x, rope.tail[4].y,
            //     rope.tail[5].x, rope.tail[5].y,
            //     rope.tail[6].x, rope.tail[6].y,
            //     rope.tail[7].x, rope.tail[7].y,
            //     rope.tail[8].x, rope.tail[8].y,
            // });
            moveRope(&rope, cmd.dir);
            try visitedPoints.put(rope.tail[8], {});
        }
    }

    return @intCast(u32, visitedPoints.count());
}

fn moveRope(rope: *Rope, dir: Direction) void {
    // Move the head first
    switch (dir) {
        .U => rope.head.y += 1,
        .D => rope.head.y -= 1,
        .L => rope.head.x -= 1,
        .R => rope.head.x += 1,
    }

    // Next move each of the tail points iteratively:
    // Special case for the first tail segment, because it needs to reference the head
    rope.tail[0] = moveSegment(rope.head, rope.tail[0]);

    var i: usize = 1;
    while (i < rope.tail.len) : (i += 1) {
        rope.tail[i] = moveSegment(rope.tail[i - 1], rope.tail[i]);
    }
}

// Returns the new location of the tail, given the location of head
fn moveSegment(head: Point, tail: Point) Point {
    const dx: i32 = head.x - tail.x;
    const dy: i32 = head.y - tail.y;
    var newTail = tail;

    // Detect if the tail shouldn't move at all:
    if ((dx == 0 or dx == 1 or dx == -1) and (dy == 0 or dy == 1 or dy == -1)) {
        return newTail;
    }

    //  432
    //  5T1
    //  678

    if (dx > 1 and dy == 0) { // 1
        newTail.x += 1;
    } else if (dx < -1 and dy == 0) { // 5
        newTail.x -= 1;
    } else if (dy > 1 and dx == 0) { // 3
        newTail.y += 1;
    } else if (dy < -1 and dx == 0) { // 7
        newTail.y -= 1;
    } else if (dx > 0 and dy > 0) { // 2
        newTail.x += 1;
        newTail.y += 1;
    } else if (dx < 0 and dy > 0) { // 4
        newTail.x -= 1;
        newTail.y += 1;
    } else if (dx < 0 and dy < 0) { // 6
        newTail.x -= 1;
        newTail.y -= 1;
    } else if (dx > 0 and dy < 0) { // 8
        newTail.x += 1;
        newTail.y -= 1;
    }
    return newTail;
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
