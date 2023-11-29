const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    _ = allocator;

    const part1 = try solveP1(input);
    const part2 = try solveP2(input);
    return [2]u64{ part1, part2 };
}

fn solveN(input: []const u8, count: usize) !u32 {
    var charSet: u256 = 0;
    var i: usize = 0;
    while (i < input.len - count) : (i += 1) {
        charSet = 0;
        var j: usize = 0;
        while (j < count) : (j += 1) {
            charSet |= @as(u256, 1) << input[i + j];
        }
        if (@popCount(charSet) == count) {
            return @as(u32, @intCast(i + count));
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

// After I solved day 6, I found the standard library StaticBitSet, which is exactly what I needed!
// This is still probably not the fastest way to solve this puzzle. I tried to use XOR at first,
// but couldn't get it to work, and then I read a blog post explaining how to solve it with XOR...
fn solveNBitSet(input: []const u8, count: usize) !u32 {
    var i: usize = 0;
    while (i < input.len - count) : (i += 1) {
        var bitSet = std.StaticBitSet(256).initEmpty();
        var j: usize = 0;
        while (j < count) : (j += 1) {
            bitSet.set(input[i + j]);
        }
        if (bitSet.count() == count) {
            return @as(u32, @intCast(i + count));
        }
    }
    return error.InvalidPuzzleInput;
}

test "std.StaticBitSet" {
    try std.testing.expectEqual(try solveN("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 4), try solveNBitSet("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 4));
    try std.testing.expectEqual(try solveN("bvwbjplbgvbhsrlpgdmjqwftvncz", 4), try solveNBitSet("bvwbjplbgvbhsrlpgdmjqwftvncz", 4));
    try std.testing.expectEqual(try solveN("nppdvjthqldpwncqszvftbrmjlhg", 4), try solveNBitSet("nppdvjthqldpwncqszvftbrmjlhg", 4));
    try std.testing.expectEqual(try solveN("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 4), try solveNBitSet("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 4));
    try std.testing.expectEqual(try solveN("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 4), try solveNBitSet("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 4));

    try std.testing.expectEqual(try solveN("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 14), try solveNBitSet("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 14));
    try std.testing.expectEqual(try solveN("bvwbjplbgvbhsrlpgdmjqwftvncz", 14), try solveNBitSet("bvwbjplbgvbhsrlpgdmjqwftvncz", 14));
    try std.testing.expectEqual(try solveN("nppdvjthqldpwncqszvftbrmjlhg", 14), try solveNBitSet("nppdvjthqldpwncqszvftbrmjlhg", 14));
    try std.testing.expectEqual(try solveN("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 14), try solveNBitSet("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 14));
    try std.testing.expectEqual(try solveN("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 14), try solveNBitSet("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 14));
}
