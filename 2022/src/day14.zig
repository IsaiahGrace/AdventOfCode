const std = @import("std");

const Tile = enum {
    air,
    sand,
    rock,
};

const Coord = struct {
    x: isize,
    y: isize,
};

const Cave = std.AutoHashMap(Coord, Tile);

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    var cave = try constructCave(allocator, input);
    defer cave.deinit();

    const deepestRock = try findDeepestRock(cave);
    var part1: u64 = 0;
    while (try dropSandIntoCave(cave, deepestRock, false)) |sandCoord| {
        try cave.put(sandCoord, .sand);
        part1 += 1;
    }

    var part2 = part1;
    while (try dropSandIntoCave(cave, deepestRock, true)) |sandCoord| {
        try cave.put(sandCoord, .sand);
        part2 += 1;
    }

    return [2]u64{ part1, part2 };
}

// Drops a grain of sand into the cave and returns the coordinate of the sand after it comes to rest,
// or null if the sand grain falls off into infinity (or if there's nowhere for it to go)!
fn dropSandIntoCave(cave: Cave, deepestRock: Coord, floor: bool) !?Coord {
    var sandPos = Coord{ .x = 500, .y = 0 };

    if (cave.get(sandPos)) |tile| {
        if (tile == .sand or tile == .rock) return null;
    }

    while (sandPos.y < deepestRock.y + 1) : (sandPos.y += 1) {
        const down = Coord{ .x = sandPos.x, .y = sandPos.y + 1 };
        const left = Coord{ .x = sandPos.x - 1, .y = sandPos.y + 1 };
        const right = Coord{ .x = sandPos.x + 1, .y = sandPos.y + 1 };
        const downTile = cave.get(down);
        const leftTile = cave.get(left);
        const rightTile = cave.get(right);

        if (downTile == null or downTile.? == .air) {
            continue;
        }

        if (leftTile == null or leftTile.? == .air) {
            sandPos.x -= 1;
            continue;
        }

        if (rightTile == null or rightTile.? == .air) {
            sandPos.x += 1;
            continue;
        }

        // We can't move down, left, or right. So this is it
        return sandPos;
    }

    if (floor) {
        // The sand has fallen onto the floor and now will pile up.
        return sandPos;
    } else {
        // The sand has fallen below the deepest rock, so it goes down into the abyss!
        return null;
    }
}

fn findDeepestRock(cave: Cave) !Coord {
    var deepestRock: ?Coord = null;

    var tiles = cave.iterator();
    while (tiles.next()) |tile| {
        if (tile.value_ptr.* != .rock) continue;
        if (deepestRock) |*rock| {
            if (tile.key_ptr.y > rock.*.y) {
                rock.* = tile.key_ptr.*;
            }
        } else {
            deepestRock = tile.key_ptr.*;
        }
    }

    if (deepestRock) |rock| {
        return rock;
    } else {
        return error.NoRocksFoundInCave;
    }
}

fn constructCave(allocator: std.mem.Allocator, input: []u8) !Cave {
    var cave = Cave.init(allocator);
    errdefer cave.deinit();

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var coords = std.mem.split(u8, line, " -> ");

        // Special case for the first coord on a line:
        var start: Coord = undefined;
        var startNumbers = std.mem.tokenize(u8, coords.next().?, ",");
        start.x = try std.fmt.parseUnsigned(isize, startNumbers.next().?, 10);
        start.y = try std.fmt.parseUnsigned(isize, startNumbers.next().?, 10);

        while (coords.next()) |coord| {
            var numbers = std.mem.tokenize(u8, coord, ",");
            const end = Coord{
                .x = try std.fmt.parseUnsigned(isize, numbers.next().?, 10),
                .y = try std.fmt.parseUnsigned(isize, numbers.next().?, 10),
            };

            // There shouldn't be any more numbers (i.e. 12,5,3)
            std.debug.assert(numbers.next() == null);

            // Now that we have a starting and ending coordinate, let's draw the rock formation on the cave!
            if (start.x == end.x) {
                try drawVerticalLine(&cave, start, end);
            } else if (start.y == end.y) {
                try drawHorizontalLine(&cave, start, end);
            } else {
                // Diagonal line, illegal!
                return error.InvalidPuzzleInput;
            }

            // The end of the current line segment become the start of the next line segment
            start = end;
        }
    }
    return cave;
}

fn drawVerticalLine(cave: *Cave, start: Coord, end: Coord) !void {
    std.debug.assert(start.x == end.x);
    const x = start.x;
    const endY = if (start.y >= end.y) start.y else end.y;
    var y = if (start.y >= end.y) end.y else start.y;

    // We'll always place at least one tile on the map (i.e. if start == end)
    try cave.*.put(Coord{ .x = x, .y = endY }, .rock);

    while (y != endY) : (y += 1) {
        try cave.*.put(Coord{ .x = x, .y = y }, .rock);
    }
}

fn drawHorizontalLine(cave: *Cave, start: Coord, end: Coord) !void {
    std.debug.assert(start.y == end.y);
    const y = start.y;
    const endX = if (start.x >= end.x) start.x else end.x;
    var x = if (start.x >= end.x) end.x else start.x;

    // See drawVerticalLine for explanation.
    try cave.*.put(Coord{ .x = endX, .y = y }, .rock);
    while (x != endX) : (x += 1) {
        try cave.*.put(Coord{ .x = x, .y = y }, .rock);
    }
}
