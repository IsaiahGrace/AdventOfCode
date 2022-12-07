const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u32 {
    _ = allocator;

    const part1 = try solveP1(input);
    const part2: u32 = 0;
    return [2]u32{ part1, part2 };
}

fn solveP1(input: []const u8) !u32 {
    for (input) |_, i| {
        const w = input[i .. i + 4];
        std.log.info("{c} {c} {c} {c}", .{ w[0], w[1], w[2], w[3] });
        if (w[0] != w[1] and w[0] != w[2] and w[0] != w[3]) {
            if (w[1] != w[2] and w[1] != w[3]) {
                if (w[2] != w[3]) {
                    return @intCast(u32, i) + 4;
                }
            }
        }
    }
    return error.InvalidPuzzleInput;
}

test "part1" {
    try std.testing.expectEqual(try solveP1("mjqjpqmgbljsphdztnvjfqwrcgsmlb"), 7);
    try std.testing.expectEqual(try solveP1("bvwbjplbgvbhsrlpgdmjqwftvncz"), 5);
    try std.testing.expectEqual(try solveP1("nppdvjthqldpwncqszvftbrmjlhg"), 6);
    try std.testing.expectEqual(try solveP1("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"), 10);
    try std.testing.expectEqual(try solveP1("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"), 11);
}
