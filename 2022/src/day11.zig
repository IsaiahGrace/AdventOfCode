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

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    const monkeysP1 = try parseMonkeys(allocator, input);
    defer {
        for (monkeysP1) |*monkey|
            monkey.items.deinit();
        allocator.free(monkeysP1);
    }
    const part1 = try solveP1(monkeysP1);

    const monkeysP2 = try parseMonkeys(allocator, input);
    defer {
        for (monkeysP2) |*monkey|
            monkey.items.deinit();
        allocator.free(monkeysP2);
    }
    const part2 = try solveP2(monkeysP2);

    return [2]u64{ part1, part2 };
}

fn solveP2(monkeys: []Monkey) !u64 {
    var commonMultiple: u64 = 1;
    for (monkeys) |monkey| {
        commonMultiple *= monkey.testDivisibleBy;
    }

    var i: u32 = 0;
    while (i < 10000) : (i += 1) {
        try playRound(monkeys, commonMultiple);
    }

    // for (monkeys) |monkey, j| {
    //     std.log.info("Monkey {d} inspected items {d} times.", .{ j, monkey.inspectedCount });
    // }

    return getMonkeyBuisness(monkeys);
}

fn solveP1(monkeys: []Monkey) !u64 {
    var i: u8 = 0;
    while (i < 20) : (i += 1) {
        try playRound(monkeys, null);
    }
    return getMonkeyBuisness(monkeys);
}

fn getMonkeyBuisness(monkeys: []const Monkey) u64 {
    var first: u64 = 0;
    var second: u64 = 0;
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

fn playRound(monkeys: []Monkey, lcm: ?u64) !void {
    for (monkeys) |*monkey| {
        while (monkey.items.popOrNull()) |item| {
            monkey.inspectedCount += 1;
            var new = switch (monkey.operation.operator) {
                .square => item * item,
                .add => item + monkey.operation.operand,
                .mul => item * monkey.operation.operand,
            };

            if (lcm) |cm| {
                new = new % cm;
            } else {
                new = new / 3;
            }

            if (new % monkey.testDivisibleBy == 0) {
                try monkeys[monkey.trueMonkey].items.append(new);
            } else {
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

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    // This line is ignored because all monkeys are defined in order.
    const monkeyLine = lines.next().?;
    _ = monkeyLine;

    const itemLine = lines.next().?;
    var itemTokens = std.mem.tokenizeSequence(u8, itemLine, ":,");
    _ = itemTokens.next().?;
    while (itemTokens.next()) |item| {
        const trimmedItem = std.mem.trim(u8, item, " ");
        try monkey.items.append(try std.fmt.parseUnsigned(u64, trimmedItem, 10));
    }

    const operationLine = lines.next().?;
    var opTokens = std.mem.tokenizeScalar(u8, operationLine, '=');
    _ = opTokens.next().?;
    const operation = opTokens.next().?;
    if (std.mem.count(u8, operation, "old") == 2) {
        monkey.operation.operator = .square;
        monkey.operation.operand = 0;
    } else {
        var args = std.mem.tokenizeScalar(u8, operation, ' ');
        _ = args.next().?;
        monkey.operation.operator = @enumFromInt(args.next().?[0]);
        monkey.operation.operand = try std.fmt.parseUnsigned(u64, args.next().?, 10);
    }

    const testLine = lines.next().?;
    var testLineTokens = std.mem.tokenizeScalar(u8, testLine, ' ');
    var last = testLineTokens.next().?;
    while (testLineTokens.next()) |token| {
        last = token;
    }
    monkey.testDivisibleBy = try std.fmt.parseUnsigned(u64, last, 10);

    const trueMonkeyLine = lines.next().?;
    var trueMonkeyTokens = std.mem.tokenizeScalar(u8, trueMonkeyLine, ' ');
    last = trueMonkeyTokens.next().?;
    while (trueMonkeyTokens.next()) |token| {
        last = token;
    }
    monkey.trueMonkey = try std.fmt.parseUnsigned(usize, last, 10);

    const falseMonkeyLine = lines.next().?;
    var falseMonkeyTokens = std.mem.tokenizeScalar(u8, falseMonkeyLine, ' ');
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
