const std = @import("std");

const asc = std.sort.asc(u32);

pub fn solve(allocator: std.mem.Allocator, input: []u8) !void {
    var it = std.mem.split(u8, input, "\n");

    var elves: []u32 = try allocator.alloc(u32, countElves(input));
    std.mem.set(u32, elves, 0);

    var i: u32 = 0;

    while (it.next()) |line| {
        if (line.len == 0) {
            i += 1;
            continue;
        }
        elves[i] += try std.fmt.parseUnsigned(u32, line, 10);
    }

    std.sort.sort(u32, elves, {}, asc);

    for (elves) |elf, x| {
        std.log.info("{d}: {d}", .{ x, elf });
    }

    const part1 = elves[elves.len - 1];
    const part2 = elves[elves.len - 1] + elves[elves.len - 2] + elves[elves.len - 3];

    std.log.info("Part 1 solution: {d}", .{part1});
    std.log.info("Part 2 solution: {d}", .{part2});
}

fn countElves(input: []const u8) usize {
    var it = std.mem.split(u8, input, "\n");
    var count: u32 = 0;
    while (it.next()) |line| {
        if (line.len == 0) {
            count += 1;
        }
    }
    return count;
}
