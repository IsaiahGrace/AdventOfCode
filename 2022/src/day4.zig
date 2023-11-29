const std = @import("std");

const intersectionType = struct {
    fullyContains: bool,
    overlaps: bool,
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    _ = allocator;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var part1: u32 = 0;
    var part2: u32 = 0;
    while (lines.next()) |line| {
        var assignemts = std.mem.tokenizeScalar(u8, line, ',');
        const set1 = assignemts.next().?;
        const set2 = assignemts.next().?;
        const intersections = try findIntersections(set1, set2);
        if (intersections.fullyContains) {
            part1 += 1;
        }
        if (intersections.overlaps) {
            part2 += 1;
        }
    }

    return [2]u64{ part1, part2 };
}

fn findIntersections(set1: []const u8, set2: []const u8) !intersectionType {
    var set1Tokens = std.mem.tokenizeScalar(u8, set1, '-');
    var set2Tokens = std.mem.tokenizeScalar(u8, set2, '-');

    const set1Bounds = [2]u32{ try std.fmt.parseInt(u32, set1Tokens.next().?, 10), try std.fmt.parseInt(u32, set1Tokens.next().?, 10) };
    const set2Bounds = [2]u32{ try std.fmt.parseInt(u32, set2Tokens.next().?, 10), try std.fmt.parseInt(u32, set2Tokens.next().?, 10) };

    var intersections = intersectionType{
        .fullyContains = false,
        .overlaps = false,
    };

    // Check if set 1 is fully contained in set 2
    if (set1Bounds[0] >= set2Bounds[0] and set1Bounds[1] <= set2Bounds[1]) {
        intersections.fullyContains = true;
    }

    // Check if set 2 is fully contained in set 1
    if (set2Bounds[0] >= set1Bounds[0] and set2Bounds[1] <= set1Bounds[1]) {
        intersections.fullyContains = true;
    }

    // Check if set 1 intersects with set 2
    if (set1Bounds[0] >= set2Bounds[0] and set1Bounds[0] <= set2Bounds[1]) {
        intersections.overlaps = true;
    }
    if (set1Bounds[1] >= set2Bounds[0] and set1Bounds[1] <= set2Bounds[1]) {
        intersections.overlaps = true;
    }

    // Check if set 2 intersects with set 1
    if (set2Bounds[0] >= set1Bounds[0] and set2Bounds[0] <= set1Bounds[1]) {
        intersections.overlaps = true;
    }
    if (set2Bounds[1] >= set1Bounds[0] and set2Bounds[1] <= set1Bounds[1]) {
        intersections.overlaps = true;
    }

    return intersections;
}

test "findIntersections" {
    try std.testing.expectEqual(try findIntersections("2-4", "6-8"), .{ .fullyContains = false, .overlaps = false });
    try std.testing.expectEqual(try findIntersections("2-3", "4-5"), .{ .fullyContains = false, .overlaps = false });
    try std.testing.expectEqual(try findIntersections("5-7", "7-9"), .{ .fullyContains = false, .overlaps = true });
    try std.testing.expectEqual(try findIntersections("2-8", "3-7"), .{ .fullyContains = true, .overlaps = true });
    try std.testing.expectEqual(try findIntersections("6-6", "4-6"), .{ .fullyContains = true, .overlaps = true });
    try std.testing.expectEqual(try findIntersections("2-6", "4-8"), .{ .fullyContains = false, .overlaps = true });
}
