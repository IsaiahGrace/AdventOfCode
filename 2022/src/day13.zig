const std = @import("std");

const Value = union(enum) {
    item: u32,
    list: Packet,
};

const Packet = std.ArrayList(Value);

const Pair = struct {
    left: Packet,
    right: Packet,
};

const Signal = std.ArrayList(Pair);

pub fn solve(allocator: std.mem.Allocator, input: []const u8) ![2]u64 {
    const signal = try parseSignal(allocator, input);
    defer deinitSignal(signal);

    const part1 = try solveP1(allocator, signal);

    // Create a list of all packets:
    var packets = std.ArrayList(Packet).init(allocator);
    defer packets.deinit();
    for (signal.items) |p| {
        try packets.append(p.left);
        try packets.append(p.right);
    }

    const divPacket2 = try parsePacketList(allocator, "[[2]]");
    defer deinitPacket(divPacket2);
    const divPacket6 = try parsePacketList(allocator, "[[6]]");
    defer deinitPacket(divPacket6);

    try packets.append(divPacket2);
    try packets.append(divPacket6);

    std.mem.sort(Packet, packets.items, allocator, packetLessThan);

    var divPacket2Index: u64 = 0;
    var divPacket6Index: u64 = 0;
    for (packets.items, 0..) |p, i| {
        if (orderPackets(allocator, p, divPacket2) == std.math.Order.eq) {
            divPacket2Index = i;
        }
        if (orderPackets(allocator, p, divPacket6) == std.math.Order.eq) {
            divPacket6Index = i;
        }
    }

    const part2 = (divPacket2Index + 1) * (divPacket6Index + 1);

    return [2]u64{ part1, part2 };
}

fn packetLessThan(allocator: std.mem.Allocator, left: Packet, right: Packet) bool {
    if (orderPackets(allocator, left, right) == std.math.Order.lt) {
        return true;
    } else {
        return false;
    }
}

fn solveP1(allocator: std.mem.Allocator, signal: Signal) !u64 {
    var orderedPairs = std.ArrayList(u64).init(allocator);
    defer orderedPairs.deinit();

    for (signal.items, 0..) |p, i| {
        if (orderPackets(allocator, p.left, p.right) == std.math.Order.lt) {
            try orderedPairs.append(i + 1);
        }
    }

    var part1: u64 = 0;
    for (orderedPairs.items) |i| {
        part1 += i;
    }
    return part1;
}

fn orderPackets(allocator: std.mem.Allocator, left: Packet, right: Packet) std.math.Order {
    var i: usize = 0;
    while (i < left.items.len) : (i += 1) {
        if (i >= right.items.len) return std.math.Order.gt;

        if (left.items[i] == .item and right.items[i] == .item) {
            if (left.items[i].item > right.items[i].item) return std.math.Order.gt;
            if (left.items[i].item < right.items[i].item) return std.math.Order.lt;
        } else if (left.items[i] == .list and right.items[i] == .list) {
            const ordering = orderPackets(allocator, left.items[i].list, right.items[i].list);
            if (ordering != std.math.Order.eq) return ordering;
        } else if (left.items[i] == .list) {
            var rightPacket = Packet.init(allocator);
            defer rightPacket.deinit();
            rightPacket.append(Value{ .item = right.items[i].item }) catch unreachable;
            const ordering = orderPackets(allocator, left.items[i].list, rightPacket);
            if (ordering != std.math.Order.eq) return ordering;
        } else if (right.items[i] == .list) {
            var leftPacket = Packet.init(allocator);
            defer leftPacket.deinit();
            leftPacket.append(Value{ .item = left.items[i].item }) catch unreachable;
            const ordering = orderPackets(allocator, leftPacket, right.items[i].list);
            if (ordering != std.math.Order.eq) return ordering;
        }
    }

    // If Both lists run out of items, then the ordering is inconclusive
    if (i == right.items.len) return std.math.Order.eq;

    // If just the left packet ran out, then the ordering is known.
    return std.math.Order.lt;
}

fn parseSignal(allocator: std.mem.Allocator, input: []const u8) !Signal {
    var signal = Signal.init(allocator);
    errdefer deinitSignal(signal);

    var pairs = std.mem.split(u8, input, "\n\n");
    while (pairs.next()) |pair| {
        var lines = std.mem.tokenizeScalar(u8, pair, '\n');
        const left = lines.next().?;
        const right = lines.next().?;
        if (lines.next() != null) return error.InvalidPuzzleInput;
        try signal.append(try parsePair(allocator, left, right));
    }

    return signal;
}

fn parsePair(allocator: std.mem.Allocator, left: []const u8, right: []const u8) !Pair {
    var pair: Pair = undefined;

    pair.left = try parsePacketList(allocator, left);
    errdefer deinitPacket(pair.left);

    pair.right = try parsePacketList(allocator, right);

    return pair;
}

fn parsePacketList(allocator: std.mem.Allocator, packet: []const u8) anyerror!Packet {
    var packetList = Packet.init(allocator);
    errdefer deinitPacket(packetList);

    // A Packet is a list of Values, which can either be an Item, or a Packet
    if (packet.len == 0 or packet[0] != '[') return error.InvalidPuzzleInput;

    var i: usize = 1;
    while (i < packet.len) : (i += 1) {
        switch (packet[i]) {
            '[' => {
                // Find the slice of the sub-list, and recurse on it
                var depth: usize = 1;
                var end: usize = i + 1;
                while (depth > 0) : (end += 1) {
                    switch (packet[end]) {
                        '[' => depth += 1,
                        ']' => depth -= 1,
                        else => {},
                    }
                }
                const newPacketList = try parsePacketList(allocator, packet[i..end]);
                try packetList.append(Value{ .list = newPacketList });
                i = end - 1;
            },
            ']' => {
                // If we've reached a closing brace, we better be at the end of a list!
                if (i + 1 != packet.len) return error.InvalidPuzzleInput;
                return packetList;
            },
            ',' => {
                // We don't allow zero sized values.
                if (i + 1 == packet.len) return error.InvalidPuzzleInput;
                if (packet[i + 1] == ',') return error.InvalidPuzzleInput;
                if (packet[i + 1] == ']') return error.InvalidPuzzleInput;
            },
            '0'...'9' => {
                var end: usize = i;
                while (packet[end] >= '0' and packet[end] <= '9') : (end += 1) {}
                const newItem: u32 = try std.fmt.parseUnsigned(u32, packet[i..end], 10);
                try packetList.append(Value{ .item = newItem });
                i = end - 1;
            },
            else => return error.InvalidPuzzleInput,
        }
    }
    return error.InvalidPuzzleInput;
}

fn deinitSignal(signal: Signal) void {
    for (signal.items) |*pair| {
        deinitPacket(pair.*.left);
        deinitPacket(pair.*.right);
    }
    signal.deinit();
}

fn deinitPacket(packet: Packet) void {
    for (packet.items) |*value| {
        if (value.* == .list) {
            deinitPacket(value.*.list);
        }
    }
    packet.deinit();
}

test "parsePacketList" {
    const allocator = std.testing.allocator;
    const p1 = try parsePacketList(allocator, "[]");
    deinitPacket(p1);

    const p2 = try parsePacketList(allocator, "[1]");
    deinitPacket(p2);

    const p3 = try parsePacketList(allocator, "[1,2]");
    deinitPacket(p3);

    const p4 = try parsePacketList(allocator, "[1,[1,2]]");
    deinitPacket(p4);

    const p5 = try parsePacketList(allocator, "[32234,342,[4324,234]]");
    deinitPacket(p5);

    try std.testing.expectError(error.InvalidPuzzleInput, parsePacketList(allocator, "[,,]"));
    try std.testing.expectError(error.InvalidPuzzleInput, parsePacketList(allocator, "["));
    try std.testing.expectError(error.InvalidPuzzleInput, parsePacketList(allocator, ""));
    try std.testing.expectError(error.Overflow, parsePacketList(allocator, "[123412412431234]"));
}
