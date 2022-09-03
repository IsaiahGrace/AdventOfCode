const std = @import("std");
const fileIo = @import("fileIo.zig");

pub fn main() !void {
    if (std.os.argv.len != 2) {
        std.log.err("Please specify an input file containing the puzzle information", .{});
        return error.NoArguments;
    }

    // We'll use a simple arena allocator.
    // The deinit call below will free ALL memory allocated with this allocator.
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    // Okay, we have argv[1], which is a sentinel terminated pointer (there's a \0 at the end).
    // Zig arrays always have a known length, so we need to calcuate the lenght of argv[1] before we can cast it to an array.
    // Note: The array will still have the sentinel value,
    const argLen = std.mem.len(std.os.argv[1]);
    const filePath = std.os.argv[1][0..argLen :0];

    // The above is equivelent to:
    // const filePath = std.mem.slice(std.os.argv[1]);
    // But I've kept it explicit to help me learn.

    std.log.info("File path = {s}", .{filePath});

    const buffer = try fileIo.readFileIntoBuffer(&allocator, filePath);

    std.log.info("File contents:\n{s}", .{buffer});
}

fn readFileIntoBuffer(allocator: *const std.mem.Allocator, filePath: []const u8) ![]u8 {
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
