const std = @import("std");

const Tree = struct {
    height: u4,
    visible: bool,
};

// 1. We can allocate a 2d array up front by finding the length of the first line and the number of lines.
//    The puzzle is guaranteed to be a rectangle.
//
// 2. Parse the input and read it into our 2d array. Set every tree to not visible.
//
// 3. Go inward from each edge of the forest, setting trees to visible as appropriate.
//
// 4. Go over every tree in the forest, counting the visible ones.

// Bonus: Print out the forest, and use colors/boldness to show which trees are visible?

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u32 {
    const dimensions = findDimensions(input);

    var forest: [][]Tree = try allocator.alloc([]Tree, dimensions[0]);
    defer allocator.free(forest);

    for (forest) |*row| {
        row.* = try allocator.alloc(Tree, dimensions[1]);
    }
    defer {
        for (forest) |row| {
            allocator.free(row);
        }
    }

    loadForest(forest, input);

    calculateVisibility(forest);
    //try printForest(allocator, forest);

    const part1 = countVisible(forest);
    return [2]u32{ part1, 0 };
}

fn countVisible(forest: []const []const Tree) u32 {
    var visibleCount: u32 = 0;
    for (forest) |row| {
        for (row) |tree| {
            if (tree.visible) {
                visibleCount += 1;
            }
        }
    }
    return visibleCount;
}

fn calculateVisibility(forest: [][]Tree) void {
    lookEast(forest);
    lookWest(forest);
    lookNorth(forest);
    lookSouth(forest);
}

fn lookEast(forest: [][]Tree) void {
    for (forest) |*row| {
        var maxHeight: ?u4 = null;
        for (row.*) |*tree| {
            if (maxHeight == null or tree.height > maxHeight.?) {
                tree.visible = true;
                maxHeight = tree.height;
                if (tree.height == 9) {
                    break;
                }
            }
        }
    }
}

fn lookWest(forest: [][]Tree) void {
    for (forest) |*row| {
        var col = row.len;
        var maxHeight: ?u4 = null;
        while (col > 0) {
            col -= 1;
            var tree: *Tree = &row.*[col];
            if (maxHeight == null or tree.height > maxHeight.?) {
                tree.visible = true;
                maxHeight = tree.height;
                if (tree.height == 9) {
                    break;
                }
            }
        }
    }
}

fn lookSouth(forest: [][]Tree) void {
    var col: usize = 0;
    while (col < forest[0].len) : (col += 1) {
        var row: usize = 0;
        var maxHeight: ?u4 = null;
        while (row < forest.len) : (row += 1) {
            var tree: *Tree = &forest[row][col];
            if (maxHeight == null or tree.height > maxHeight.?) {
                tree.visible = true;
                maxHeight = tree.height;
                if (tree.height == 9) {
                    break;
                }
            }
        }
    }
}

fn lookNorth(forest: [][]Tree) void {
    var col: usize = 0;
    while (col < forest[0].len) : (col += 1) {
        var row: usize = forest.len;
        var maxHeight: ?u4 = null;
        while (row > 0) {
            row -= 1;
            var tree: *Tree = &forest[row][col];
            if (maxHeight == null or tree.height > maxHeight.?) {
                tree.visible = true;
                maxHeight = tree.height;
                if (tree.height == 9) {
                    break;
                }
            }
        }
    }
}

fn printForest(allocator: std.mem.Allocator, forest: []const []const Tree) !void {
    var printBuffer = std.ArrayList(u8).init(allocator);
    defer printBuffer.deinit();

    var green: bool = false;
    for (forest) |row| {
        for (row) |tree| {
            if (tree.visible) {
                if (!green) {
                    try printBuffer.appendSlice("\x1b[32m");
                    green = true;
                }
                try printBuffer.append(@as(u8, tree.height) + '0');
            } else {
                if (green) {
                    try printBuffer.appendSlice("\x1b[0m");
                    green = false;
                }
                try printBuffer.append(@as(u8, tree.height) + '0');
            }
        }
        try printBuffer.append('\n');
    }

    try printBuffer.appendSlice("\x1b[0m");
    std.log.info("Forest:\n{s}", .{printBuffer.items});
}

fn loadForest(forest: [][]Tree, input: []const u8) void {
    var lines = std.mem.tokenize(u8, input, "\n");

    var row: usize = 0;
    while (lines.next()) |line| : (row += 1) {
        for (line) |char, col| {
            forest[row][col].height = @intCast(u4, char - '0');
            forest[row][col].visible = false;
        }
    }
}

fn findDimensions(input: []const u8) [2]u32 {
    var lines = std.mem.tokenize(u8, input, "\n");

    const cols = @intCast(u32, lines.next().?.len);
    lines.reset();

    var rows: u32 = 0;
    while (lines.next() != null) {
        rows += 1;
    }

    return [2]u32{ rows, cols };
}
