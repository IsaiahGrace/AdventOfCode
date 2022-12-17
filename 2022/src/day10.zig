const std = @import("std");

const OpcodeTypes = enum {
    addx,
    noop,
};

const Opcode = union(OpcodeTypes) {
    addx: i32,
    noop: void,
};

const CPU = struct {
    const Self = @This();

    clk: u32,
    x: i32,
    signalStrengthSum: i32,

    fn exec(self: *Self, opcode: Opcode) void {
        self.tick();
        switch (opcode) {
            .addx => |v| {
                self.tick();
                self.x += v;
            },
            .noop => {},
        }
    }

    fn tick(self: *Self) void {
        if ((self.clk + 20) % 40 == 0) {
            const signalStrength = @intCast(i32, self.clk) * self.x;
            //std.log.info("Clk: {:3<}  x: {d} signalStrength: {d}", .{ self.clk, self.x, signalStrength });
            self.signalStrengthSum += signalStrength;
        } else {
            //std.log.info("Clk: {:3<}  x: {d}", .{ self.clk, self.x });
        }
        self.clk += 1;
    }
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]i32 {
    _ = allocator;

    var cpu = CPU{
        .clk = 1,
        .x = 1,
        .signalStrengthSum = 0,
    };

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        const op = try getOpcode(line);
        //std.log.info("{s}", .{line});
        cpu.exec(op);
    }

    return [2]i32{ cpu.signalStrengthSum, 0 };
}

fn getOpcode(line: []const u8) !Opcode {
    var tokens = std.mem.tokenize(u8, line, " ");
    const op = tokens.next().?;
    if (std.mem.eql(u8, op, "noop")) {
        return Opcode{
            .noop = {},
        };
    }

    if (std.mem.eql(u8, op, "addx")) {
        return Opcode{
            .addx = try std.fmt.parseInt(i32, tokens.next().?, 10),
        };
    }

    return error.InvalidPuzzleInput;
}
