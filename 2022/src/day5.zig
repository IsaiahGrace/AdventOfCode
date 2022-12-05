const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2][]u8 {
    _ = input;
    const part1 = try allocator.alloc(u8, 3);
    const part2 = try allocator.alloc(u8, 3);
    std.mem.copy(u8, part1, "ABC");
    std.mem.copy(u8, part2, "XYZ");
    return [2][]u8{ part1, part2 };
}
