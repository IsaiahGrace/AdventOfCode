const std = @import("std");

const OpcodeTypes = enum {
    addx,
    noop,
};

const Opcode = union(OpcodeTypes) {
    addx: i32,
    noop: void,
};

const ScreenBuffer = struct {
    const Self = @This();

    rows: [6][40]u8,
    frame: u32,

    fn drawPixel(self: *Self, clk: u32, x: i32) void {
        const clkRow = ((clk - 1) / 40) % 6;
        const clkCol = (clk - 1) % 40;
        var row = &self.rows[clkRow];
        if (x == clkCol or (x + 1) == clkCol or (x - 1) == clkCol) {
            row.*[clkCol] = '#';
        }
        //self.print();
        //std.log.info("x: {d} clk: {d} clkRow: {d} clkCol: {d}", .{ x, clk, clkRow, clkCol });
    }

    // Prints the display to stdout:
    fn print(self: *Self) void {
        std.log.info("{:^40}", .{self.frame});
        for (self.rows) |row| {
            std.log.info("{s}", .{row});
        }
        self.frame += 1;
    }
};

const CPU = struct {
    const Self = @This();

    clk: u32,
    x: i32,
    signalStrengthSum: i32,
    screen: ScreenBuffer,

    fn init() Self {
        var self = CPU{
            .clk = 1,
            .x = 1,
            .signalStrengthSum = 0,
            .screen = undefined,
        };
        for (self.screen.rows) |*row| {
            for (row.*) |*col| {
                col.* = '.';
            }
        }
        self.screen.frame = 0;
        return self;
    }

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

        self.screen.drawPixel(self.clk, self.x);

        // Print the screen after every 240 clock cycles (1 full screen refresh)
        if ((self.clk % 240) == 0) {
            self.screen.print();
        }

        self.clk += 1;
    }
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]i32 {
    _ = allocator;

    var cpu = CPU.init();

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
