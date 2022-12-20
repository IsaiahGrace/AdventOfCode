const std = @import("std");

const Operators = enum(u8) {
    square,
    add = '+',
    mul = '*',
};

const Operation = struct {
    operator: Operators,
    operand: u64,
};

const Monkey = struct {
    items: std.ArrayList(u64),
    operation: Operation,
    testDivisibleBy: u64,
    trueMonkey: usize,
    falseMonkey: usize,
    inspectedCount: u32,
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u32 {
    _ = allocator;
    _ = input;

    var monkeys = try parseMonkeys(allocator, input);
    defer {
        for (monkeys) |*monkey|
            monkey.items.deinit();
        allocator.free(monkeys);
    }

    const part1 = try solveP1(monkeys);

    return [2]u32{ part1, 0 };
}

fn solveP1(monkeys: []Monkey) !u32 {
    var i: u8 = 0;
    while (i < 20) : (i += 1) {
        try playRound(monkeys);
    }

    // Get the top two monkeys and calcualte the monkey buisness.
    var first: u32 = 0;
    var second: u32 = 0;
    for (monkeys) |monkey| {
        if (monkey.inspectedCount > first) {
            second = first;
            first = monkey.inspectedCount;
        } else if (monkey.inspectedCount > second) {
            second = monkey.inspectedCount;
        }
    }

    return first * second;
}

fn playRound(monkeys: []Monkey) !void {
    for (monkeys) |*monkey| {
        while (monkey.items.popOrNull()) |item| {
            //std.log.info("monkey: {d}, item worry: {d}", .{ i, item });
            monkey.inspectedCount += 1;
            var new = switch (monkey.operation.operator) {
                .square => item * item,
                .add => item + monkey.operation.operand,
                .mul => item * monkey.operation.operand,
            };
            new = new / 3;
            if (new % monkey.testDivisibleBy == 0) {
                //std.log.info("monkey: {d}, throws {d} to {d}", .{ i, new, monkey.trueMonkey });
                try monkeys[monkey.trueMonkey].items.append(new);
            } else {
                //std.log.info("monkey: {d}, throws {d} to {d}", .{ i, new, monkey.falseMonkey });
                try monkeys[monkey.falseMonkey].items.append(new);
            }
        }
    }
}

fn parseMonkeys(allocator: std.mem.Allocator, input: []const u8) ![]Monkey {
    var monkeys = std.ArrayList(Monkey).init(allocator);

    var monkeyLines = std.mem.split(u8, input, "\n\n");

    while (monkeyLines.next()) |lines| {
        try monkeys.append(try parseMonkey(allocator, lines));
    }

    return monkeys.toOwnedSlice();
}

fn parseMonkey(allocator: std.mem.Allocator, input: []const u8) !Monkey {
    var monkey: Monkey = undefined;
    monkey.items = std.ArrayList(u64).init(allocator);
    monkey.inspectedCount = 0;

    var lines = std.mem.tokenize(u8, input, "\n");

    // This line is ignored because all monkeys are defined in order.
    const monkeyLine = lines.next().?;
    _ = monkeyLine;

    const itemLine = lines.next().?;
    var itemTokens = std.mem.tokenize(u8, itemLine, ":,");
    _ = itemTokens.next().?;
    while (itemTokens.next()) |item| {
        const trimmedItem = std.mem.trim(u8, item, " ");
        try monkey.items.append(try std.fmt.parseUnsigned(u64, trimmedItem, 10));
    }

    const operationLine = lines.next().?;
    var opTokens = std.mem.tokenize(u8, operationLine, "=");
    _ = opTokens.next().?;
    const operation = opTokens.next().?;
    if (std.mem.count(u8, operation, "old") == 2) {
        monkey.operation.operator = .square;
        monkey.operation.operand = 0;
    } else {
        var args = std.mem.tokenize(u8, operation, " ");
        _ = args.next().?;
        monkey.operation.operator = @intToEnum(Operators, args.next().?[0]);
        monkey.operation.operand = try std.fmt.parseUnsigned(u64, args.next().?, 10);
    }

    const testLine = lines.next().?;
    var testLineTokens = std.mem.tokenize(u8, testLine, " ");
    var last = testLineTokens.next().?;
    while (testLineTokens.next()) |token| {
        last = token;
    }
    monkey.testDivisibleBy = try std.fmt.parseUnsigned(u64, last, 10);

    const trueMonkeyLine = lines.next().?;
    var trueMonkeyTokens = std.mem.tokenize(u8, trueMonkeyLine, " ");
    last = trueMonkeyTokens.next().?;
    while (trueMonkeyTokens.next()) |token| {
        last = token;
    }
    monkey.trueMonkey = try std.fmt.parseUnsigned(usize, last, 10);

    const falseMonkeyLine = lines.next().?;
    var falseMonkeyTokens = std.mem.tokenize(u8, falseMonkeyLine, " ");
    last = falseMonkeyTokens.next().?;
    while (falseMonkeyTokens.next()) |token| {
        last = token;
    }
    monkey.falseMonkey = try std.fmt.parseUnsigned(usize, last, 10);

    if (lines.next() != null) {
        return error.InvalidPuzzleInput;
    }

    return monkey;
}
