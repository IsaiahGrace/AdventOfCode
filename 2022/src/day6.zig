const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u32 {
    _ = allocator;

    const part1 = try solveP1(input);
    const part2 = try solveP2(input);
    return [2]u32{ part1, part2 };
}

fn solveN(input: []const u8, count: usize) !u32 {
    var charSet: [256]u1 = undefined;
    var i: usize = 0;
    while (i < input.len - count) : (i += 1) {
        std.mem.set(u1, &charSet, 0);
        var j: usize = 0;
        while (j < count) : (j += 1) {
            charSet[input[i + j]] = 1;
        }
        var bits: u32 = 0;
        for (charSet) |bit| {
            bits += bit;
        }
        if (bits == count) {
            return @intCast(u32, i + count);
        }
    }
    return error.InvalidPuzzleInput;
}

fn solveP1(input: []const u8) !u32 {
    return solveN(input, 4);
}

fn solveP2(input: []const u8) !u32 {
    return solveN(input, 14);
}

test "part1" {
    try std.testing.expectEqual(try solveP1("mjqjpqmgbljsphdztnvjfqwrcgsmlb"), 7);
    try std.testing.expectEqual(try solveP1("bvwbjplbgvbhsrlpgdmjqwftvncz"), 5);
    try std.testing.expectEqual(try solveP1("nppdvjthqldpwncqszvftbrmjlhg"), 6);
    try std.testing.expectEqual(try solveP1("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"), 10);
    try std.testing.expectEqual(try solveP1("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"), 11);
}

test "part2" {
    try std.testing.expectEqual(try solveP2("mjqjpqmgbljsphdztnvjfqwrcgsmlb"), 19);
    try std.testing.expectEqual(try solveP2("bvwbjplbgvbhsrlpgdmjqwftvncz"), 23);
    try std.testing.expectEqual(try solveP2("nppdvjthqldpwncqszvftbrmjlhg"), 23);
    try std.testing.expectEqual(try solveP2("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"), 29);
    try std.testing.expectEqual(try solveP2("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"), 26);
}
