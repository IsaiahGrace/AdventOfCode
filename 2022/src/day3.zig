const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    _ = allocator;
    var lines = std.mem.tokenize(u8, input, "\n");

    var part1: u32 = 0;
    while (lines.next()) |line| {
        part1 += try findPriority(line);
    }

    lines.reset();

    var part2: u32 = 0;
    while (lines.next()) |line1| {
        const line2 = lines.next().?;
        const line3 = lines.next().?;
        part2 += try findBadge(line1, line2, line3);
    }

    return [2]u64{ part1, part2 };
}

fn findPriority(line: []const u8) !u8 {
    // This array is larger than necessary, but allows direct indexing by ASCII value
    var firstCompartmentSet = [_]bool{false} ** (1 << 8);

    const half = (line.len / 2);
    // Create a set of items in the first compartment
    for (line[0..half]) |char| {
        firstCompartmentSet[char] = true;
    }

    // Look through the second compartment for items already in the set
    for (line[half..]) |char| {
        if (firstCompartmentSet[char]) {
            return getItemPriority(char);
        }
    }

    // If we didn't find any items in the second compartment which are also in the first, then the
    // input is Invalid.
    return error.InvalidPuzzleInput;
}

fn findBadge(line1: []const u8, line2: []const u8, line3: []const u8) !u8 {
    // These arrays are way larger than needed, but allows direct ASCII indexing.
    var elf1TypeSet = [_]u8{0} ** (1 << 8);
    var elf2TypeSet = [_]u8{0} ** (1 << 8);
    var elf3TypeSet = [_]u8{0} ** (1 << 8);

    for (line1) |char| {
        elf1TypeSet[char] = 1;
    }

    for (line2) |char| {
        elf2TypeSet[char] = 1;
    }

    for (line3) |char| {
        elf3TypeSet[char] = 1;
    }

    var i: u8 = 0;
    while (i < (1 << 8)) : (i += 1) {
        if ((elf1TypeSet[i] + elf2TypeSet[i] + elf3TypeSet[i]) == 3) {
            return getItemPriority(i);
        }
    }

    return error.InvalidPuzzleInput;
}

fn getItemPriority(item: u8) !u8 {
    if (item >= 'a' and item <= 'z') {
        return item - 'a' + 1;
    } else if (item >= 'A' and item <= 'Z') {
        return item - 'A' + 27;
    }
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

test "findBadge" {
    try std.testing.expectEqual(try findBadge("vJrwpWtwJgWrhcsFMMfFFhFp", "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL", "PmmdzqPrVvPwwTWBwg"), 18);
    try std.testing.expectEqual(try findBadge("wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn", "ttgJtRGJQctTZtZT", "CrZsJsPPZsGzwwsLwLmpwMDw"), 52);
}

test "getItemPriority" {
    try std.testing.expectEqual(try getItemPriority('a'), 1);
    try std.testing.expectEqual(try getItemPriority('z'), 26);
    try std.testing.expectEqual(try getItemPriority('A'), 27);
    try std.testing.expectEqual(try getItemPriority('Z'), 52);

    try std.testing.expectError(error.InvalidPuzzleInput, getItemPriority('_'));
    try std.testing.expectError(error.InvalidPuzzleInput, getItemPriority('@'));
    try std.testing.expectError(error.InvalidPuzzleInput, getItemPriority('\n'));
    try std.testing.expectError(error.InvalidPuzzleInput, getItemPriority(0));
}
