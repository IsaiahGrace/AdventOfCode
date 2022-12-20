const std = @import("std");

const asc = std.sort.asc(u32);

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    var it = std.mem.split(u8, input, "\n");

    var elves = std.ArrayList(u32).init(allocator);
    defer elves.deinit();

    try elves.append(0);

    while (it.next()) |line| {
        if (line.len == 0) {
            try elves.append(0);
        } else {
            elves.items[elves.items.len - 1] += try std.fmt.parseUnsigned(u32, line, 10);
        }
    }

    std.sort.sort(u32, elves.items, {}, asc);

    const part1 = elves.items[elves.items.len - 1];
    const part2 = elves.items[elves.items.len - 1] + elves.items[elves.items.len - 2] + elves.items[elves.items.len - 3];

    return [2]u64{ part1, part2 };
}
