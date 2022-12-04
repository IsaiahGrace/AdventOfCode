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

    const buffer = try fileIo.readFileIntoBuffer(allocator, filePath);

    std.log.info("File contents:\n{s}", .{buffer});

    //var caves = try parseInputBuffer(buffer);

    var caveMap: std.BufMap = std.BufMap.init(allocator);
    try caveMap.put("hello", "map!");
    std.log.info("{s} = {s}", .{ "hello", caveMap.get("hello") });
}

// We have a "hashing" algorithm for our cave names, the literal u16 values of the two characters!

const CaveTag = packed struct {
    c1: u8,
    c2: u8,
    c3: u8, // If this byte is nonzero, the cave is either the start or the end
    c4: u8, // If this byte is nonzero, the cave is the start
};

comptime {
    // @compileLog(@bitSizeOf(CaveTag));
    // @compileLog(@bitSizeOf(u32));
    std.debug.assert(@sizeOf(CaveTag) == @sizeOf(u32));
    std.debug.assert(@bitSizeOf(CaveTag) == @bitSizeOf(u32));
}

const Size = enum {
    small,
    large,
};

const Cave = struct {
    id: u32,
    tag: CaveTag,
    size: Size,
    visitedCount: u32,

    // fn fromString(buffer: []const u8) !Cave {
    //     var cave: Cave = undefined;
    //     var c = buffer[0];
    // }
};

//fn parseInputBuffer(buffer: []const u8) ![]Cave {}
