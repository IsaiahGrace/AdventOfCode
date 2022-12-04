const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u32 {
    _ = allocator;

    var lines = std.mem.tokenize(u8, input, "\n");

    var part1: u32 = 0;
    while (lines.next()) |line| {
        var assignemts = std.mem.tokenize(u8, line, ",");
        if (try fullyContains(assignemts.next().?, assignemts.next().?)) {
            part1 += 1;
        }
        if (assignemts.next() != null) {
            return error.InvalidPuzzleInput;
        }
    }

    return [2]u32{ part1, 0 };
}

fn fullyContains(set1: []const u8, set2: []const u8) !bool {
    var set1Tokens = std.mem.tokenize(u8, set1, "-");
    var set2Tokens = std.mem.tokenize(u8, set2, "-");

    const set1Bounds = [2]u32{ try std.fmt.parseInt(u32, set1Tokens.next().?, 10), try std.fmt.parseInt(u32, set1Tokens.next().?, 10) };
    const set2Bounds = [2]u32{ try std.fmt.parseInt(u32, set2Tokens.next().?, 10), try std.fmt.parseInt(u32, set2Tokens.next().?, 10) };

    // Check if set 1 is fully contained in set 2
    if (set1Bounds[0] >= set2Bounds[0] and set1Bounds[1] <= set2Bounds[1]) {
        return true;
    }

    // Check if set 2 is fully contained in set 1
    if (set2Bounds[0] >= set1Bounds[0] and set2Bounds[1] <= set1Bounds[1]) {
        return true;
    }

    return false;
}

test "fullyContains" {
    try std.testing.expectEqual(try fullyContains("2-4", "6-8"), false);
    try std.testing.expectEqual(try fullyContains("2-3", "4-5"), false);
    try std.testing.expectEqual(try fullyContains("5-7", "7-9"), false);
    try std.testing.expectEqual(try fullyContains("2-8", "3-7"), true);
    try std.testing.expectEqual(try fullyContains("6-6", "4-6"), true);
    try std.testing.expectEqual(try fullyContains("2-6", "4-8"), false);
}
