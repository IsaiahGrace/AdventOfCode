// const io = @import("std").io;
// const log = @import("std").log;
// const os = @import("std").os;
const std = @import("std");
//const testing = @import("std").testing;

pub fn main() !void {
    if (std.os.argv.len != 2) {
        std.log.err("Please specify an input file containing the puzzle information", .{});
        return error.NoArguments;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const filePath = try std.fmt.allocPrint(allocator, "{s}", .{std.os.argv[1]});
    std.log.info("File path = {s}", .{filePath});

    const buffer = try readFileIntoBuffer(&allocator, filePath);
    defer allocator.free(buffer);

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
