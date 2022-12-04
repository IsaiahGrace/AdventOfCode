const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u32 {
    _ = allocator;
    var lines = std.mem.tokenize(u8, input, "\n");

    var part1: u32 = 0;

    while (lines.next()) |line| {
        part1 += try findPriority(line);
    }

    return [2]u32{ part1, 0 };
}

fn findPriority(line: []const u8) !u8 {
    // This array is larger than necessary, but allows direct indexing by ASCII value
    var firstCompartmentSet = [_]bool{false} ** (1 << 8);

    const half = (line.len / 2);
    // Create a set of items in the first compartment
    for (line[0..half]) |char| {
        firstCompartmentSet[char] = true;
    }

    // Look trhough the second compartment for items already in the set
    for (line[half..]) |char| {
        if (firstCompartmentSet[char]) {
            if (char >= 'a' and char <= 'z') {
                return char - 'a' + 1;
            } else if (char >= 'A' and char <= 'Z') {
                return char - 'A' + 27;
            } else {
                return error.InvalidPuzzleInput;
            }
        }
    }

    // If we didn't find any items in the second compartment which are also in the first, then the
    // input is Invalid.
    return error.InvalidPuzzleInput;
}

test "findPriority" {
    try std.testing.expectEqual(try findPriority("vJrwpWtwJgWrhcsFMMfFFhFp"), 16);
    try std.testing.expectEqual(try findPriority("jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL"), 38);
    try std.testing.expectEqual(try findPriority("PmmdzqPrVvPwwTWBwg"), 42);
    try std.testing.expectEqual(try findPriority("wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn"), 22);
    try std.testing.expectEqual(try findPriority("ttgJtRGJQctTZtZT"), 20);
    try std.testing.expectEqual(try findPriority("CrZsJsPPZsGzwwsLwLmpwMDw"), 19);

    try std.testing.expectError(error.InvalidPuzzleInput, findPriority("vJrwpWtwJgWrhcsFMMfFFhFx"));
    try std.testing.expectError(error.InvalidPuzzleInput, findPriority(""));
}
