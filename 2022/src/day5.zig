const std = @import("std");

const Stack = std.ArrayList(u8);

const Move = struct {
    count: u8,
    from: u8,
    to: u8,
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2][]u8 {
    var stacksP1 = try constructStacks(allocator, input);
    defer {
        for (stacksP1) |*stack| {
            stack.deinit();
        }
        allocator.free(stacksP1);
    }

    var stacksP2 = try constructStacks(allocator, input);
    defer {
        for (stacksP2) |*stack| {
            stack.deinit();
        }
        allocator.free(stacksP2);
    }

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next().?[1] != '1') {}

    while (lines.next()) |line| {
        const move = try parseMove(line);
        //printStacks(&stacksP2);
        //std.log.info("move {d} from {d} to {d}", .{ move.count, move.from, move.to });
        try executeSingleMove(&stacksP1, move);
        try executeMultiMove(&stacksP2, move);
    }

    //printStacks(&stacksP2);

    const part1 = try allocator.alloc(u8, stacksP1.len);
    errdefer allocator.free(part1);
    for (stacksP1, 0..) |stack, i| {
        part1[i] = stack.items[stack.items.len - 1];
    }

    const part2 = try allocator.alloc(u8, stacksP2.len);
    errdefer allocator.free(part1);
    for (stacksP2, 0..) |stack, i| {
        part2[i] = stack.items[stack.items.len - 1];
    }

    return [2][]u8{ part1, part2 };
}

fn executeMultiMove(stacks: *[]Stack, move: Move) !void {
    const fromIdx = stacks.*[move.from].items.len - move.count;
    try stacks.*[move.to].appendSlice(stacks.*[move.from].items[fromIdx..]);
    stacks.*[move.from].shrinkRetainingCapacity(fromIdx);
}

fn executeSingleMove(stacks: *[]Stack, move: Move) !void {
    var count: u8 = 0;
    while (count < move.count) : (count += 1) {
        try stacks.*[move.to].append(stacks.*[move.from].pop());
    }
}

fn parseMove(line: []const u8) !Move {
    var move: Move = undefined;
    var tokens = std.mem.tokenizeScalar(u8, line, ' ');
    if (!std.mem.eql(u8, tokens.next().?, "move")) {
        return error.InvalidPuzzleInput;
    }
    move.count = try std.fmt.parseInt(u8, tokens.next().?, 10);

    if (!std.mem.eql(u8, tokens.next().?, "from")) {
        return error.InvalidPuzzleInput;
    }
    move.from = try std.fmt.parseInt(u8, tokens.next().?, 10);

    if (!std.mem.eql(u8, tokens.next().?, "to")) {
        return error.InvalidPuzzleInput;
    }
    move.to = try std.fmt.parseInt(u8, tokens.next().?, 10);

    // The puzzle input stacks are 1 based, but ours are 0 based
    move.from -= 1;
    move.to -= 1;
    return move;
}

fn printStacks(stacks: *const []Stack) void {
    for (stacks.*, 0..) |stack, i| {
        std.log.info("Stack: {d} = {s}", .{ i, stack.items });
    }
}

fn constructStacks(allocator: std.mem.Allocator, input: []u8) ![]Stack {
    const numStacks = try getNumberOfStacks(input);
    var stacks = try allocator.alloc(Stack, numStacks);
    for (stacks) |*stack| {
        stack.* = Stack.init(allocator);
    }

    // Now that we have stacks to place our crates in, we need to parse the input file:
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line[1] == '1') {
            break;
        }

        var col = std.mem.indexOfScalarPos(u8, line, 0, '[');
        while (col) |i| {
            const crateLoc: usize = i / 4;
            try stacks[crateLoc].insert(0, line[i + 1]);
            col = std.mem.indexOfScalarPos(u8, line, i + 1, '[');
        }
    }

    return stacks;
}

fn getNumberOfStacks(input: []u8) !u8 {
    // The first few lines of the puzzle input look like this:
    //     [D]
    // [N] [C]
    // [Z] [M] [P]
    //  1   2   3
    // We're going to go through the lines and look at the second character until we see '1'.
    // Then we're going to go across that line and count the number of stacks.
    // We won't parse the stack numbers or, or even verify that they are digits.
    // This seems like a relatively fragile way to parse the input, but it is safe to make these
    // assumptions because we have a guarantee that the input is well-formed.

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    const indexLine = indexLine: {
        while (lines.next()) |line| {
            if (line[1] == '1') {
                break :indexLine line;
            }
        }
        return error.InvalidPuzzleInput;
    };

    var stacks = std.mem.tokenizeScalar(u8, indexLine, ' ');
    var numStacks: u8 = 0;
    while (stacks.next() != null) {
        numStacks += 1;
    }

    return numStacks;
}
