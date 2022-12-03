const std = @import("std");
const day1 = @import("day1.zig");

pub fn main() anyerror!void {
    if (std.os.argv.len != 3) {
        std.log.err("Usage:", .{});
        std.log.err("<day number> (testX|input)", .{});
        return error.NoArguments;
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const dayStr = std.mem.span(std.os.argv[1]);
    const dayInt = try std.fmt.parseUnsigned(u8, dayStr, 10);

    const file = std.mem.span(std.os.argv[2]);

    const filePath = try std.mem.join(allocator, "/", &.{ dayStr, file });

    std.log.info("Input path: {s}", .{filePath});

    const buffer = try readFileIntoBuffer(allocator, filePath);

    switch (dayInt) {
        1 => try day1.solve(allocator, buffer),
        else => std.log.err("Unknown day", .{}),
    }
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
