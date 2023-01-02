const std = @import("std");

const Coord = struct {
    x: isize,
    y: isize,
};

const Set = std.AutoHashMap(Coord, void);

const Cave = struct {
    const Self = @This();

    map: Set,
    deepest: isize,
    floor: bool,

    fn init(allocator: std.mem.Allocator, input: []u8) !Self {
        var cave = Cave{
            .map = Set.init(allocator),
            .deepest = 0,
            .floor = false,
        };
        errdefer cave.map.deinit();

        var lines = std.mem.tokenize(u8, input, "\n");
        while (lines.next()) |line| {
            var coords = std.mem.split(u8, line, " -> ");

            // Special case for the first coord on a line:
            var startNumbers = std.mem.tokenize(u8, coords.next().?, ",");
            var start = Coord{
                .x = try std.fmt.parseUnsigned(isize, startNumbers.next().?, 10),
                .y = try std.fmt.parseUnsigned(isize, startNumbers.next().?, 10),
            };

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
                    try cave.drawVerticalLine(start, end);
                } else if (start.y == end.y) {
                    try cave.drawHorizontalLine(start, end);
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

    fn drawVerticalLine(self: *Self, start: Coord, end: Coord) !void {
        std.debug.assert(start.x == end.x);
        const x = start.x;
        const endY = if (start.y >= end.y) start.y else end.y;
        var y = if (start.y >= end.y) end.y else start.y;

        // We'll always place at least one tile on the map (i.e. if start == end)
        try self.map.put(Coord{ .x = x, .y = endY }, {});
        while (y < endY) : (y += 1) {
            try self.map.put(Coord{ .x = x, .y = y }, {});
        }

        if (endY > self.deepest) {
            self.deepest = endY;
        }
    }

    fn drawHorizontalLine(self: *Self, start: Coord, end: Coord) !void {
        std.debug.assert(start.y == end.y);
        const y = start.y;
        const endX = if (start.x >= end.x) start.x else end.x;
        var x = if (start.x >= end.x) end.x else start.x;

        // See drawVerticalLine for explanation.
        try self.map.put(Coord{ .x = endX, .y = y }, {});
        while (x < endX) : (x += 1) {
            try self.map.put(Coord{ .x = x, .y = y }, {});
        }

        if (y > self.deepest) {
            self.deepest = y;
        }
    }

    // Drops a grain of sand into the cave and returns the coordinate of the sand after it comes to rest,
    // or null if the sand grain falls off into infinity (or if there's nowhere for it to go)!
    fn dropSandIntoCave(self: Self) !?Coord {
        var sandPos = Coord{ .x = 500, .y = 0 };

        if (self.map.get(sandPos) != null) return null;

        while (sandPos.y < self.deepest + 1) : (sandPos.y += 1) {
            const down = Coord{ .x = sandPos.x, .y = sandPos.y + 1 };
            if (self.map.get(down) == null) {
                continue;
            }

            const left = Coord{ .x = sandPos.x - 1, .y = sandPos.y + 1 };
            if (self.map.get(left) == null) {
                sandPos.x -= 1;
                continue;
            }

            const right = Coord{ .x = sandPos.x + 1, .y = sandPos.y + 1 };
            if (self.map.get(right) == null) {
                sandPos.x += 1;
                continue;
            }

            // We can't move down, left, or right. So this is it
            return sandPos;
        }

        // The sand has fallen below the deepest rock

        if (self.floor) {
            // The sand has fallen onto the floor and now will pile up.
            return sandPos;
        } else {
            // The sand has fallen below the deepest rock, so it goes down into the abyss!
            return null;
        }
    }
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    var cave = try Cave.init(allocator, input);
    defer cave.map.deinit();

    var part1: u64 = 0;
    while (try cave.dropSandIntoCave()) |sandCoord| {
        try cave.map.put(sandCoord, {});
        part1 += 1;
    }

    cave.floor = true;
    var part2 = part1;
    while (try cave.dropSandIntoCave()) |sandCoord| {
        try cave.map.put(sandCoord, {});
        part2 += 1;
    }

    return [2]u64{ part1, part2 };
}
