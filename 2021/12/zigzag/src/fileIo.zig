const std = @import("std");

pub fn readFileIntoBuffer(allocator: *const std.mem.Allocator, filePath: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(filePath, .{ .read = true, .write = false });
    defer file.close();

    const fileSize = try file.getEndPos();
    std.log.info("File size = {d}", .{fileSize});

    var buffer = try allocator.alloc(u8, fileSize);
    errdefer allocator.free(buffer);
    std.log.info("Buffer len = {d}", .{buffer.len});

    _ = try file.readAll(buffer);

    return buffer;
}
