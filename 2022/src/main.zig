const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day7 = @import("day7.zig");
const day8 = @import("day8.zig");

pub fn main() anyerror!void {
    if (std.os.argv.len != 3) {
        std.log.err("Usage: <day number> <input file name>", .{});
        std.log.err("Program expects a file <day>/<input> to exist.", .{});
        return error.NoArguments;
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const dayStr = std.mem.span(std.os.argv[1]);
    const day = try std.fmt.parseUnsigned(u8, dayStr, 10);

    const file = std.mem.span(std.os.argv[2]);
    const filePath = try std.mem.join(allocator, "/", &.{ dayStr, file });
    defer allocator.free(filePath);

    // Geez, day 5 really broke the trend, and made everything much harder...
    if (day == 5) {
        const solutions = try solveStrPuzzle(allocator, day, filePath);
        std.log.info("Part 1 solution: {s}", .{solutions[0]});
        std.log.info("Part 2 solution: {s}", .{solutions[1]});
        allocator.free(solutions[0]);
        allocator.free(solutions[1]);
    } else {
        const solutions = try solveIntPuzzle(allocator, day, filePath);
        std.log.info("Part 1 solution: {d}", .{solutions[0]});
        std.log.info("Part 2 solution: {d}", .{solutions[1]});
    }
}

// I'm breaking this up into a separate function so I can test it bellow for all the days.
fn solveIntPuzzle(allocator: std.mem.Allocator, day: u8, filePath: []const u8) ![2]u32 {
    const buffer = try readFileIntoBuffer(allocator, filePath);
    defer allocator.free(buffer);

    return switch (day) {
        1 => try day1.solve(allocator, buffer),
        2 => try day2.solve(allocator, buffer),
        3 => try day3.solve(allocator, buffer),
        4 => try day4.solve(allocator, buffer),
        5 => error.InvalidDay,
        6 => try day6.solve(allocator, buffer),
        7 => try day7.solve(allocator, buffer),
        8 => try day8.solve(allocator, buffer),
        else => error.InvalidDay,
    };
}

fn solveStrPuzzle(allocator: std.mem.Allocator, day: u8, filePath: []const u8) ![2][]u8 {
    const buffer = try readFileIntoBuffer(allocator, filePath);
    defer allocator.free(buffer);

    return switch (day) {
        5 => try day5.solve(allocator, buffer),
        else => error.InvalidDay,
    };
}

pub fn readFileIntoBuffer(allocator: std.mem.Allocator, filePath: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(filePath, .{});
    defer file.close();

    const fileSize = try file.getEndPos();

    var buffer = try allocator.alloc(u8, fileSize);
    errdefer allocator.free(buffer);

    const bytesRead = try file.readAll(buffer);

    if (bytesRead != fileSize) {
        return error.FileNotFullyRead;
    }

    return buffer;
}

test "day1" {
    var allocator = std.testing.allocator;
    try std.testing.expectEqual(try solveIntPuzzle(allocator, 1, "1/input"), .{ 69528, 206152 });
}

test "day2" {
    var allocator = std.testing.allocator;
    try std.testing.expectEqual(try solveIntPuzzle(allocator, 2, "2/input"), .{ 11475, 16862 });
}

test "day3" {
    var allocator = std.testing.allocator;
    try std.testing.expectEqual(try solveIntPuzzle(allocator, 3, "3/input"), .{ 7691, 2508 });
}

test "day4" {
    var allocator = std.testing.allocator;
    try std.testing.expectEqual(try solveIntPuzzle(allocator, 4, "4/input"), .{ 530, 903 });
}

test "day5" {
    var allocator = std.testing.allocator;
    const day5Solution = try solveStrPuzzle(allocator, 5, "5/input");
    defer allocator.free(day5Solution[0]);
    defer allocator.free(day5Solution[1]);
    try std.testing.expectEqualStrings(day5Solution[0], "RNZLFZSJH");
    try std.testing.expectEqualStrings(day5Solution[1], "CNSFCGJSM");
}

test "day6" {
    var allocator = std.testing.allocator;
    try std.testing.expectEqual(try solveIntPuzzle(allocator, 6, "6/input"), .{ 1651, 3837 });
}

test "day7" {
    var allocator = std.testing.allocator;
    try std.testing.expectEqual(try solveIntPuzzle(allocator, 7, "7/input"), .{ 1491614, 6400111 });
}

test "day8" {
    var allocator = std.testing.allocator;
    try std.testing.expectEqual(try solveIntPuzzle(allocator, 8, "8/input"), .{ 1538, 0 });
}
