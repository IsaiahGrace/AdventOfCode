const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    var left = std.ArrayList(u32).init(allocator);
    defer left.deinit();

    var right = std.ArrayList(u32).init(allocator);
    defer right.deinit();

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeAny(u8, line, " ");
        try left.append(try std.fmt.parseInt(u32, numbers.next().?, 10));
        try right.append(try std.fmt.parseInt(u32, numbers.next().?, 10));
        std.debug.assert(numbers.next() == null);
    }

    std.mem.sort(u32, left.items, {}, std.sort.asc(u32));
    std.mem.sort(u32, right.items, {}, std.sort.asc(u32));

    var sum: u32 = 0;
    for (left.items, right.items) |l, r| {
        sum += @abs(@as(i32, @intCast(l)) - @as(i32, @intCast(r)));
    }

    return [2]u64{ sum, 0 };
}
