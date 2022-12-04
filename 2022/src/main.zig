const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");

pub fn main() anyerror!void {
    if (std.os.argv.len != 3) {
        std.log.err("Usage: <day number> <input file name>", .{});
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

    const solutions = try solvePuzzle(allocator, day, filePath);

    std.log.info("Part 1 solution: {d}", .{solutions[0]});
    std.log.info("Part 2 solution: {d}", .{solutions[1]});
}

// I'm breaking this up into a separate function so I can test it bellow for all the days.
fn solvePuzzle(allocator: std.mem.Allocator, day: u8, filePath: []const u8) ![2]u32 {
    const buffer = try readFileIntoBuffer(allocator, filePath);
    defer allocator.free(buffer);

    return switch (day) {
        1 => try day1.solve(allocator, buffer),
        2 => try day2.solve(allocator, buffer),
        3 => try day3.solve(allocator, buffer),
        else => return error.InvalidDay,
    };
}

pub fn readFileIntoBuffer(allocator: std.mem.Allocator, filePath: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(filePath, .{ .read = true, .write = false });
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

test "Everyday" {
    var allocator = std.testing.allocator;
    try std.testing.expectEqual(try solvePuzzle(allocator, 1, "1/input"), .{ 69528, 206152 });
    try std.testing.expectEqual(try solvePuzzle(allocator, 2, "2/input"), .{ 11475, 16862 });
}
