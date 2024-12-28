const std = @import("std");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");

pub fn readFileIntoBuffer(allocator: std.mem.Allocator, filePath: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(filePath, .{});
    defer file.close();

    const fileSize = try file.getEndPos();

    const buffer = try allocator.alloc(u8, fileSize);
    errdefer allocator.free(buffer);

    const bytesRead = try file.readAll(buffer);

    std.debug.assert(bytesRead == fileSize);

    return buffer;
}

pub fn main() anyerror!void {
    if (std.os.argv.len < 3) {
        std.log.err("Usage: <day number> <input file name>", .{});
        std.log.err("Program expects a file <day>/<input> to exist.", .{});
        return error.NoArguments;
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const dayStr = std.mem.span(std.os.argv[1]);
    const day = try std.fmt.parseInt(u8, dayStr, 10);

    const file = std.mem.span(std.os.argv[2]);
    const filePath = try std.mem.join(allocator, "/", &.{ dayStr, file });
    defer allocator.free(filePath);

    const stdOut = std.io.getStdOut().writer();

    const solutions = try solvePuzzle(allocator, day, filePath);
    try stdOut.print("Part 1 solution: {d}\n", .{solutions[0]});
    try stdOut.print("Part 2 solution: {d}\n", .{solutions[1]});
}

fn solvePuzzle(allocator: std.mem.Allocator, day: u8, filePath: []const u8) ![2]u64 {
    const buffer = try readFileIntoBuffer(allocator, filePath);
    defer allocator.free(buffer);

    return switch (day) {
        1 => try day01.solve(allocator, buffer),
        2 => try day02.solve(allocator, buffer),
        else => error.InvalidDay,
    };
}

test "day01" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(try solvePuzzle(allocator, 1, "01/input"), .{ 1873376, 0 });
    try std.testing.expectEqual(try solvePuzzle(allocator, 1, "01/test1"), .{ 11, 0 });
}
