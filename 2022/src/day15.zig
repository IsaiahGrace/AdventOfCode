const std = @import("std");
const pc = @import("puzzleContext.zig");

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
};

const Beacon = struct {
    pos: Pos,
    distToSensor: i64,
};

const Map = std.AutoHashMap(Sensor, Beacon);

const Cave = struct {
    const Self = @This();

    sensors: Map,
    leftBoundary: i64,
    rightBoundary: i64,

    fn init(allocator: std.mem.Allocator, input: []u8) !Self {
        var cave = Cave{
            .sensors = Map.init(allocator),
            .leftBoundary = std.math.maxInt(i64),
            .rightBoundary = std.math.minInt(i64),
        };
        errdefer cave.sensors.deinit();

        var lines = std.mem.tokenize(u8, input, "\n");
        while (lines.next()) |line| {
            const sensorXeql = std.mem.indexOfScalar(u8, line, '=').?;
            const sensorXcomma = std.mem.indexOfScalarPos(u8, line, sensorXeql, ',').?;
            const sensorYeql = std.mem.indexOfScalarPos(u8, line, sensorXcomma, '=').?;
            const sensorYcolon = std.mem.indexOfScalarPos(u8, line, sensorYeql, ':').?;

            const beaconXeql = std.mem.indexOfScalarPos(u8, line, sensorYcolon, '=').?;
            const beaconXcomma = std.mem.indexOfScalarPos(u8, line, beaconXeql, ',').?;
            const beaconYeql = std.mem.indexOfScalarPos(u8, line, beaconXcomma, '=').?;

            const sensor = Sensor{
                .pos = Pos{
                    .x = try std.fmt.parseInt(i64, line[sensorXeql + 1 .. sensorXcomma], 10),
                    .y = try std.fmt.parseInt(i64, line[sensorYeql + 1 .. sensorYcolon], 10),
                },
            };

            const beaconPos = Pos{
                .x = try std.fmt.parseInt(i64, line[beaconXeql + 1 .. beaconXcomma], 10),
                .y = try std.fmt.parseInt(i64, line[beaconYeql + 1 ..], 10),
            };

            const beacon = Beacon{
                .pos = beaconPos,
                .distToSensor = dist(sensor.pos, beaconPos),
            };

            try cave.sensors.put(sensor, beacon);

            if (cave.leftBoundary > (sensor.pos.x - beacon.distToSensor)) cave.leftBoundary = sensor.pos.x - beacon.distToSensor;
            if (cave.rightBoundary < (sensor.pos.x + beacon.distToSensor)) cave.rightBoundary = sensor.pos.x + beacon.distToSensor;
        }
        std.debug.assert(cave.leftBoundary < cave.rightBoundary);
        return cave;
    }

    // This function returns a number of +x units that can safely be traversed before an unknown tile might be encountered
    fn traverseSensorX(self: Self, pos: Pos) i64 {
        if (self.getSensorInRange(pos)) |s| {
            const dy = std.math.absInt(pos.y - s.pos.y) catch unreachable;
            const dx = pos.x - s.pos.x;
            const sensorRange = self.sensors.get(s).?.distToSensor;
            return sensorRange - dy - dx + 1;
        } else {
            return 1;
        }
    }

    // Returns a sensor in range of the position.
    fn getSensorInRange(self: Self, pos: Pos) ?Sensor {
        var sensors = self.sensors.iterator();
        while (sensors.next()) |s| {
            const distToSensor = dist(pos, s.key_ptr.pos);
            if (distToSensor <= s.value_ptr.distToSensor) {
                return s.key_ptr.*;
            }
        }
        return null;
    }

    // Returns the tile type for the given position
    fn get(self: Self, pos: Pos) Tile {
        var sensors = self.sensors.iterator();
        while (sensors.next()) |s| {
            const distToSensor = dist(pos, s.key_ptr.pos);
            const distToBeacon = dist(pos, s.value_ptr.pos);
            if (distToSensor == 0) return .Sensor;
            if (distToBeacon == 0) return .Beacon;
            if (distToSensor <= s.value_ptr.distToSensor) return .Empty;
        }
        return .Unknown;
    }

    fn findEmpty(self: Self, lowerLimit: i64, upperLimit: i64) !Pos {
        var pos = Pos{
            .x = lowerLimit,
            .y = lowerLimit,
        };
        while (pos.y <= upperLimit) : (pos.y += 1) {
            while (pos.x <= upperLimit) : (pos.x += self.traverseSensorX(pos)) {
                if (self.get(pos) == .Unknown) {
                    return pos;
                }
            }
            pos.x = lowerLimit;
        }
        return error.InvalidInputPuzzle;
    }
};

pub fn solve(allocator: std.mem.Allocator, input: []u8, context: pc.Context) ![2]u64 {
    var cave = try Cave.init(allocator, input);
    defer cave.sensors.deinit();

    const part1 = solveP1(cave, context.day15.row);

    const distressLocation = try cave.findEmpty(context.day15.lowerLimit, context.day15.upperLimit);

    const part2 = distressLocation.x * 4000000 + distressLocation.y;

    return [2]u64{ @intCast(u64, part1), @intCast(u64, part2) };
}

fn dist(from: Pos, to: Pos) i64 {
    const dx = std.math.absInt(from.x - to.x) catch unreachable;
    const dy = std.math.absInt(from.y - to.y) catch unreachable;
    return dx + dy;
}

fn solveP1(cave: Cave, row: i64) u64 {
    var count: u64 = 0;
    var col = cave.leftBoundary;
    while (col <= cave.rightBoundary) : (col += 1) {
        if (cave.get(Pos{ .x = col, .y = row }) == .Empty) {
            count += 1;
        }
    }

    return count;
}
