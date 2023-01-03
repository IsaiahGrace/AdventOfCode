const std = @import("std");

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

    // Returns true if the given position is nearer to a sensor than that sensors beacon
    fn isPosEmpty(self: Self, pos: Pos) bool {
        var sensors = self.sensors.iterator();
        while (sensors.next()) |s| {
            const distToSensor = dist(pos, s.key_ptr.pos);
            const distToBeacon = dist(pos, s.value_ptr.pos);
            if (distToSensor == 0) {
                std.log.info("Sensor: ({d},{d})", .{ pos.x, pos.y });
                return false;
            }
            if (distToBeacon == 0) {
                std.log.info("Beacon: ({d},{d})", .{ pos.x, pos.y });
                return false;
            }
            if (distToSensor <= s.value_ptr.distToSensor) {
                std.log.info("Empty : ({d},{d})", .{ pos.x, pos.y });
                return true;
            }
        }
        std.log.info("?????: ({d},{d})", .{ pos.x, pos.y });
        return false;
    }

    fn countEmptyRow(self: Self, row: i64) u64 {
        var count: u64 = 0;
        var col = self.leftBoundary;
        while (col <= self.rightBoundary) : (col += 1) {
            if (self.isPosEmpty(Pos{ .x = col, .y = row })) {
                count += 1;
            }
        }
        return count;
    }
};

pub fn solve(allocator: std.mem.Allocator, input: []u8, row: i64) ![2]u64 {
    var cave = try Cave.init(allocator, input);
    defer cave.sensors.deinit();

    const part1 = cave.countEmptyRow(row);

    return [2]u64{ part1, 0 };
}

fn dist(from: Pos, to: Pos) i64 {
    const dx = std.math.absInt(from.x - to.x) catch unreachable;
    const dy = std.math.absInt(from.y - to.y) catch unreachable;
    return dx + dy;
}
