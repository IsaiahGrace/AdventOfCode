const std = @import("std");
const puzzle = @import("puzzle.zig");

pub fn main() anyerror!void {
    if (std.os.argv.len != 2) {
        std.log.err("Please specify an input file containing the puzzle information", .{});
        return error.NoArguments;
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const filePath = std.mem.span(std.os.argv[1]);

    std.log.info("Input path: {s}", .{filePath});

    const buffer = try readFileIntoBuffer(allocator, filePath);

    try puzzle.solve(allocator, buffer);
}

pub fn readFileIntoBuffer(allocator: std.mem.Allocator, filePath: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(filePath, .{ .read = true, .write = false });
    defer file.close();

    const fileSize = try file.getEndPos();

    var buffer = try allocator.alloc(u8, fileSize);
    errdefer allocator.free(buffer);

    _ = try file.readAll(buffer);

    return buffer;
}
