const std = @import("std");
const pc = @import("puzzleContext.zig");

const AtomicBool = std.atomic.Atomic(bool);

const Tile = enum {
    Empty,
    Beacon,
    Sensor,
    Unknown,
};

const Pos = struct {
    x: i64,
    y: i64,
};

const Sensor = struct {
    pos: Pos,
    beacon: Pos,
    distToBeacon: i64,
};

const Cave = struct {
    const Self = @This();

    sensors: []Sensor,
    leftBoundary: i64,
    rightBoundary: i64,
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator, input: []u8) !Self {
        var cave = Cave{
            .sensors = undefined,
            .leftBoundary = std.math.maxInt(i64),
            .rightBoundary = std.math.minInt(i64),
            .allocator = allocator,
        };

        var sensors = std.ArrayList(Sensor).init(allocator);
        errdefer sensors.deinit();

        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        while (lines.next()) |line| {
            const sensorXeql = std.mem.indexOfScalar(u8, line, '=').?;
            const sensorXcomma = std.mem.indexOfScalarPos(u8, line, sensorXeql, ',').?;
            const sensorYeql = std.mem.indexOfScalarPos(u8, line, sensorXcomma, '=').?;
            const sensorYcolon = std.mem.indexOfScalarPos(u8, line, sensorYeql, ':').?;

            const beaconXeql = std.mem.indexOfScalarPos(u8, line, sensorYcolon, '=').?;
            const beaconXcomma = std.mem.indexOfScalarPos(u8, line, beaconXeql, ',').?;
            const beaconYeql = std.mem.indexOfScalarPos(u8, line, beaconXcomma, '=').?;

            const sensorPos = Pos{
                .x = try std.fmt.parseInt(i64, line[sensorXeql + 1 .. sensorXcomma], 10),
                .y = try std.fmt.parseInt(i64, line[sensorYeql + 1 .. sensorYcolon], 10),
            };

            const beaconPos = Pos{
                .x = try std.fmt.parseInt(i64, line[beaconXeql + 1 .. beaconXcomma], 10),
                .y = try std.fmt.parseInt(i64, line[beaconYeql + 1 ..], 10),
            };

            const sensor = Sensor{
                .pos = sensorPos,
                .beacon = beaconPos,
                .distToBeacon = dist(sensorPos, beaconPos),
            };

            try sensors.append(sensor);

            if (cave.leftBoundary > (sensor.pos.x - sensor.distToBeacon)) cave.leftBoundary = sensor.pos.x - sensor.distToBeacon;
            if (cave.rightBoundary < (sensor.pos.x + sensor.distToBeacon)) cave.rightBoundary = sensor.pos.x + sensor.distToBeacon;
        }
        std.debug.assert(cave.leftBoundary < cave.rightBoundary);

        cave.sensors = try sensors.toOwnedSlice();
        return cave;
    }

    fn deinit(self: *const Self) void {
        self.allocator.free(self.sensors);
    }

    /// This function returns a number of +x units that can safely be traversed before an unknown tile might be encountered
    fn traverseSensorX(self: *const Self, pos: Pos) i64 {
        if (self.getSensorInRange(pos)) |s| {
            const dy = std.math.absInt(pos.y - s.pos.y) catch unreachable;
            const dx = pos.x - s.pos.x;
            return s.distToBeacon - dy - dx + 1;
        } else {
            return 1;
        }
    }

    /// Returns a sensor in range of the position.
    fn getSensorInRange(self: *const Self, pos: Pos) ?Sensor {
        for (self.sensors) |s| {
            const distToSensor = dist(pos, s.pos);
            if (distToSensor <= s.distToBeacon) {
                return s;
            }
        }
        return null;
    }

    /// Returns the tile type for the given position
    fn get(self: *const Self, pos: Pos) Tile {
        for (self.sensors) |s| {
            const distToSensor = dist(pos, s.pos);
            const distToBeacon = dist(pos, s.beacon);
            if (distToSensor == 0) return .Sensor;
            if (distToBeacon == 0) return .Beacon;
            if (distToSensor <= s.distToBeacon) return .Empty;
        }
        return .Unknown;
    }

    /// Scans a rectangle of space for a position with unknown coontent.
    /// Bounds are inclusive. Returns null if all positions are known.
    /// Returns the first unknown position found.
    fn scanForUnknown(self: *const Self, lowerLimit: Pos, upperLimit: Pos, exitEarly: *AtomicBool) ?Pos {
        var pos = lowerLimit;
        while (pos.y <= upperLimit.y) : (pos.y += 1) {
            while (pos.x <= upperLimit.x) : (pos.x += self.traverseSensorX(pos)) {
                if (self.get(pos) == .Unknown) {
                    return pos;
                }
            }
            if (exitEarly.load(.Unordered)) return null;
            pos.x = lowerLimit.x;
        }
        return null;
    }

    /// Scans a rectangular region of space for unknown positions.
    /// Uses a number of threads to speed up the process.
    fn findEmpty(self: Self, allocator: std.mem.Allocator, lowerLimit: Pos, upperLimit: Pos) !Pos {
        const numCPUs = try std.Thread.getCpuCount();

        // We need a way to devide up the problem space into semi-equal parts, but we don't want to scan past the upper limit.
        // What we can do is create (numCPU - 1) equal slices, and then assign the THIS thread to the remaining area.
        const sliceHeight: i64 = try std.math.divFloor(i64, (upperLimit.y - lowerLimit.y), @as(i64, @intCast(numCPUs - 1)));

        var threads = try allocator.alloc(std.Thread, numCPUs - 1);
        defer allocator.free(threads);

        var pos: ?Pos = null;
        var exitEarly: AtomicBool = AtomicBool.init(false);

        for (threads, 0..) |*t, uidx| {
            const i = @as(i64, @intCast(uidx));
            const lowerSliceLimit = Pos{
                .x = lowerLimit.x,
                .y = lowerLimit.y + (i * sliceHeight),
            };
            const upperSliceLimit = Pos{
                .x = upperLimit.x,
                .y = lowerLimit.y + ((i + 1) * sliceHeight) - 1,
            };
            t.* = try std.Thread.spawn(.{}, threadWorker, .{ &self, lowerSliceLimit, upperSliceLimit, &pos, &exitEarly });
        }

        // THIS thread can search the remaining area
        const lowerRemainingLimit = Pos{
            .x = lowerLimit.x,
            .y = lowerLimit.y + (@as(i64, @intCast(numCPUs - 1)) * sliceHeight),
        };
        threadWorker(&self, lowerRemainingLimit, upperLimit, &pos, &exitEarly);

        for (threads) |t| {
            t.join();
        }

        if (pos) |p| {
            return p;
        } else {
            return error.InvalidInputPuzzle;
        }
    }
};

/// Does this have to be a 'static' function? This is what I would have to do in C++, but I don't know about zig!
fn threadWorker(cave: *const Cave, lowerLimit: Pos, upperLimit: Pos, unknownPos: *?Pos, exitEarly: *AtomicBool) void {
    // We won't always write to unknownPos, because all the threads will get the same pointer for unknownPos.
    // The puzzle is only valid if there is one unknownPos, so this isn't a data saftey issue.
    if (cave.scanForUnknown(lowerLimit, upperLimit, exitEarly)) |p| {
        unknownPos.* = p;
        exitEarly.store(true, .Unordered);
    }
}

pub fn solve(allocator: std.mem.Allocator, input: []u8, context: pc.Context) ![2]u64 {
    var cave = try Cave.init(allocator, input);
    defer cave.deinit();

    const part1 = solveP1(&cave, context.day15.row);

    const lowerLimit = Pos{
        .x = context.day15.lowerLimit,
        .y = context.day15.lowerLimit,
    };
    const upperLimit = Pos{
        .x = context.day15.upperLimit,
        .y = context.day15.upperLimit,
    };
    const distressLocation = try cave.findEmpty(allocator, lowerLimit, upperLimit);

    const part2 = distressLocation.x * 4000000 + distressLocation.y;

    return [2]u64{ @as(u64, @intCast(part1)), @as(u64, @intCast(part2)) };
}

inline fn dist(from: Pos, to: Pos) i64 {
    @setRuntimeSafety(false);
    const dx = from.x - to.x;
    const dy = from.y - to.y;
    const absDx = if (dx < 0) -dx else dx;
    const absDy = if (dy < 0) -dy else dy;
    return absDx + absDy;
}

fn solveP1(cave: *const Cave, row: i64) u64 {
    var count: u64 = 0;
    var pos = Pos{
        .x = cave.leftBoundary,
        .y = row,
    };
    while (pos.x <= cave.rightBoundary) : (pos.x += 1) {
        if (cave.get(pos) == .Empty) {
            count += 1;
        }
    }

    return count;
}
