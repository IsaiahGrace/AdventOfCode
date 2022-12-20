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

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    _ = allocator;

    var lines = std.mem.tokenize(u8, input, "\n");

    // Part 1
    var scoreP1: u32 = 0;
    while (lines.next()) |line| {
        scoreP1 += try getScoreP1(line);
    }

    lines.reset();

    // Part 2
    var scoreP2: u32 = 0;
    while (lines.next()) |line| {
        scoreP2 += try getScoreP2(line);
    }

    return [2]u64{ scoreP1, scoreP2 };
}

fn getScoreP1(line: []const u8) !u32 {
    var plays = std.mem.tokenize(u8, line, " ");

    const opponent: handShape = try parseOpponent(plays.next().?[0]);

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

    const handShapeScore: u32 = getHandShapeScore(me);
    const gameResultScore: u32 = getGameResultScore(getGameResult(opponent, me));
    return handShapeScore + gameResultScore;
}

fn getScoreP2(line: []const u8) !u32 {
    var plays = std.mem.tokenize(u8, line, " ");

    const opponent: handShape = try parseOpponent(plays.next().?[0]);

    const requiredOutcome: gameResult = switch (plays.next().?[0]) {
        'X' => .loss,
        'Y' => .draw,
        'Z' => .win,
        else => return error.InvalidPuzzleInput,
    };

    if (plays.next() != null) {
        return error.InvalidPuzzleInput;
    }

    const me: handShape = getRequiredHandShape(opponent, requiredOutcome);

    const handShapeScore = getHandShapeScore(me);

    const gameResultScore = getGameResultScore(requiredOutcome);

    return handShapeScore + gameResultScore;
}

fn parseOpponent(opponent: u8) !handShape {
    return switch (opponent) {
        'A' => .rock,
        'B' => .paper,
        'C' => .scissors,
        else => error.InvalidPuzzleInput,
    };
}

fn getHandShapeScore(me: handShape) u32 {
    return switch (me) {
        .rock => 1,
        .paper => 2,
        .scissors => 3,
    };
}

fn getGameResultScore(result: gameResult) u32 {
    return switch (result) {
        .win => 6,
        .loss => 0,
        .draw => 3,
    };
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

fn getRequiredHandShape(opponent: handShape, result: gameResult) handShape {
    switch (result) {
        .win => switch (opponent) {
            .rock => return .paper,
            .paper => return .scissors,
            .scissors => return .rock,
        },
        .loss => switch (opponent) {
            .rock => return .scissors,
            .paper => return .rock,
            .scissors => return .paper,
        },
        .draw => return opponent,
    }
}
