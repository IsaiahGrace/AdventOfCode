const std = @import("std");

// I think we need to change the hash map to be pointers to Dir, so that we can get and return pointers, instead of copies of the dirs.
// This means that we'll have to manage the allocation and destruction of the Dir objects.
const Children = std.StringHashMap(*Dir);
const Files = std.ArrayList(File);

const Dir = struct {
    name: []const u8,
    parent: ?*Dir,
    children: Children,
    files: Files,
    size: u32,
};

const File = struct {
    name: []const u8,
    size: u32,
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    var root = try initRoot(allocator, input);
    defer allocator.destroy(root);
    defer deinitDir(allocator, root);

    // const tree = try printFS(allocator, root);
    // defer allocator.free(tree);
    // std.log.info("$ tree\n{s}", .{tree});

    const part1 = try solveP1(allocator, root);
    const part2 = try solveP2(allocator, root);

    return [2]u64{ part1, part2 };
}

const asc_u32 = std.sort.asc(u32);

fn solveP1(allocator: std.mem.Allocator, root: *Dir) !u32 {
    var sizes = std.ArrayList(u32).init(allocator);
    defer sizes.deinit();
    try appendDirSizes(&sizes, root);

    std.mem.sort(u32, sizes.items, {}, asc_u32);

    var smallSizes: []u32 = undefined;
    for (sizes.items, 0..) |size, i| {
        if (size > 100000) {
            smallSizes = sizes.items[0..i];
            break;
        }
    }

    var sum: u32 = 0;
    for (smallSizes) |size| {
        sum += size;
    }

    return sum;
}

fn solveP2(allocator: std.mem.Allocator, root: *Dir) !u32 {
    const diskCapacity = 70000000;
    const requiredFreeSpace = 30000000;
    const currentlyUsedSize = root.size;
    const currentFreeSpace = diskCapacity - currentlyUsedSize;
    const targetFreeSize = requiredFreeSpace - currentFreeSpace;

    var sizes = std.ArrayList(u32).init(allocator);
    defer sizes.deinit();
    try appendDirSizes(&sizes, root);

    std.mem.sort(u32, sizes.items, {}, asc_u32);

    for (sizes.items) |size| {
        if (size > targetFreeSize) {
            return size;
        }
    }

    return error.InvalidPuzzleInput;
}

fn appendDirSizes(sizeArray: *std.ArrayList(u32), dir: *Dir) anyerror!void {
    try sizeArray.append(dir.size);
    var children = dir.children.valueIterator();
    while (children.next()) |child| {
        try appendDirSizes(sizeArray, child.*);
    }
}

fn setDirSize(dir: *Dir) u32 {
    dir.size = 0;
    for (dir.files.items) |file| {
        dir.size += file.size;
    }
    var children = dir.children.valueIterator();
    while (children.next()) |child| {
        dir.size += setDirSize(child.*);
    }
    return dir.size;
}

fn initRoot(allocator: std.mem.Allocator, input: []u8) !*Dir {
    var root = try allocator.create(Dir);
    root.parent = null;
    root.children = Children.init(allocator);
    root.files = Files.init(allocator);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var cwd: *Dir = root;

    // Special case to parse the special first line: '$ cd /'
    const firstLine = lines.next().?;
    var firstLineTokens = std.mem.tokenizeScalar(u8, firstLine, ' ');
    if (!std.mem.eql(u8, firstLineTokens.next().?, "$")) {
        return error.InvalidPuzzleInput;
    }
    if (!std.mem.eql(u8, firstLineTokens.next().?, "cd")) {
        return error.InvalidPuzzleInput;
    }
    if (firstLineTokens.next()) |rootDir| {
        root.name = rootDir;
    } else {
        return error.InvalidPuzzleInput;
    }

    while (lines.next()) |line| {
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        if (tokens.next().?[0] == '$') {
            const cmd = tokens.next().?;
            if (std.mem.eql(u8, cmd, "cd")) {
                cwd = try cd(cwd, tokens.next().?);
            }
            if (std.mem.eql(u8, cmd, "ls")) {
                // send a COPY of the lines iterator to ls(), so that it can parse the next few
                // lines without changing the current lines iterator.
                try ls(allocator, cwd, lines);
            }
        }
        // If the line doesn't start with '$', then it must be part of an ls output, so we can skip it here.
    }

    _ = setDirSize(root);
    return root;
}

fn cd(cwd: *Dir, target: []const u8) !*Dir {
    if (std.mem.eql(u8, target, "..")) {
        return cwd.parent.?;
    } else if (cwd.children.get(target)) |dir| {
        return dir;
    } else {
        return error.InvalidPuzzleInput;
    }
}

fn ls(allocator: std.mem.Allocator, cwd: *Dir, linesArg: std.mem.TokenIterator(u8, .scalar)) !void {
    // Function arguments are immutable in Zig, so we need to make a copy of the iterator.
    // This is because the compiler is free to pass either a copy of or a pointer to the args.
    var lines = linesArg;
    while (lines.next()) |line| {
        if (line[0] == '$') break;
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        const dirOrSize = tokens.next().?;
        const name = tokens.next().?;

        if (std.mem.eql(u8, dirOrSize, "dir")) {
            var newDir = try allocator.create(Dir);
            newDir.name = name;
            newDir.parent = cwd;
            newDir.children = Children.init(allocator);
            newDir.files = Files.init(allocator);
            newDir.size = 0;
            try cwd.children.putNoClobber(name, newDir);
        } else {
            const newFile = File{
                .name = name,
                .size = try std.fmt.parseUnsigned(u32, dirOrSize, 10),
            };
            try cwd.files.append(newFile);
        }
    }
}

const Writer = std.ArrayList(u8).Writer;

// The caller owns the slice
fn printFS(allocator: std.mem.Allocator, root: *Dir) anyerror![]u8 {
    var output = std.ArrayList(u8).init(allocator);
    try printDir(output.writer(), root, 0);
    return output.toOwnedSlice();
}

fn printIndent(writer: Writer, indent: u32) anyerror!void {
    var i: u32 = 0;
    while (i < indent) : (i += 1) {
        try writer.writeByte(' ');
    }
}

fn printDir(writer: Writer, cwd: *Dir, indent: u32) anyerror!void {
    try printIndent(writer, indent);
    try writer.print("- {s} (dir)\n", .{cwd.name});
    var children = cwd.children.valueIterator();
    while (children.next()) |child| {
        try printDir(writer, child.*, indent + 1);
    }
    for (cwd.files.items) |file| {
        try printFile(writer, file, indent + 1);
    }
}

fn printFile(writer: Writer, file: File, indent: u32) anyerror!void {
    try printIndent(writer, indent);
    try writer.print("- {s} (file, size={d})\n", .{ file.name, file.size });
}

fn deinitDir(allocator: std.mem.Allocator, dir: *Dir) void {
    var children = dir.children.valueIterator();
    while (children.next()) |child| {
        deinitDir(allocator, child.*);
        allocator.destroy(child.*);
    }

    dir.files.deinit();
    dir.children.deinit();
}
