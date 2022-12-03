const std = @import("std");

const gameResult = enum {
    win,
    loss,
    draw,
};

const handShape = enum {
    rock,
    paper,
    scissors,
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) !void {
    var lines = std.mem.tokenize(u8, input, "\n");

    var score: u32 = 0;

    while (lines.next()) |line| {
        score += try getScore(line);
    }

    std.log.info("Part 1 score: {d}", .{score});
    _ = allocator;
}

fn getScore(line: []const u8) !u32 {
    var plays = std.mem.tokenize(u8, line, " ");

    const opponent: handShape = switch (plays.next().?[0]) {
        'A' => .rock,
        'B' => .paper,
        'C' => .scissors,
        else => return error.InvalidPuzzleInput,
    };

    const me: handShape = switch (plays.next().?[0]) {
        'X' => .rock,
        'Y' => .paper,
        'Z' => .scissors,
        else => return error.InvalidPuzzleInput,
    };

    // Just make sure that there are only two plays per line
    if (plays.next() != null) {
        return error.InvalidPuzzleInput;
    }

    const handShapeScore: u32 = switch (me) {
        .rock => 1,
        .paper => 2,
        .scissors => 3,
    };

    const gameResultScore: u32 = switch (getGameResult(opponent, me)) {
        .win => 6,
        .loss => 0,
        .draw => 3,
    };

    return handShapeScore + gameResultScore;
}

fn getGameResult(opponent: handShape, me: handShape) gameResult {
    switch (opponent) {
        .rock => switch (me) {
            .rock => return .draw,
            .paper => return .win,
            .scissors => return .loss,
        },
        .paper => switch (me) {
            .rock => return .loss,
            .paper => return .draw,
            .scissors => return .win,
        },
        .scissors => switch (me) {
            .rock => return .win,
            .paper => return .loss,
            .scissors => return .draw,
        },
    }
}
