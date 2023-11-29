const std = @import("std");

const Tag = [2]u8;

const Connection = struct { dest: *Valve, dist: u8 };

const Valve = struct {
    tag: Tag,
    flow: u32,
    opened: bool,
    visited: u32,
    connections: std.ArrayList(Connection),
};

const Graph = struct {
    start: *Valve,
    valves: std.ArrayList(Valve),

    fn init(allocator: std.mem.Allocator, input: []u8) !Graph {
        var graph = Graph{
            .start = undefined,
            .valves = std.ArrayList(Valve).init(allocator),
        };
        errdefer graph.deinit();

        var lines = std.mem.tokenizeScalar(u8, input, '\n');

        // Create an entry for each valve
        while (lines.next()) |line| {
            var tokens = std.mem.tokenizeScalar(u8, line, ' ');
            _ = tokens.next().?; // Valve
            const tagStr = tokens.next().?[0..2]; // XX
            const tag = Tag{ tagStr[0], tagStr[1] };
            _ = tokens.next().?; // has
            _ = tokens.next().?; // flow
            const rateString = tokens.next().?; // rate=XX;
            const flow = try std.fmt.parseUnsigned(u32, rateString[5 .. rateString.len - 1], 10);
            try graph.valves.append(Valve{
                .tag = tag,
                .flow = flow,
                .opened = false,
                .visited = 0,
                .connections = std.ArrayList(Connection).init(allocator),
            });
        }
        lines.reset();

        // Fill in the valve connections, now that we know each valve is present
        while (lines.next()) |line| {
            var tokens = std.mem.tokenizeSequence(u8, line, " ,");
            _ = tokens.next().?; // Valve
            const valveTagStr = tokens.next().?[0..2]; // XX
            var valve = graph.get(Tag{ valveTagStr[0], valveTagStr[1] }).?;
            _ = tokens.next().?; // has
            _ = tokens.next().?; // flow
            _ = tokens.next().?; // rate=XX;
            _ = tokens.next().?; // tunnels
            _ = tokens.next().?; // lead
            _ = tokens.next().?; // to
            _ = tokens.next().?; // valve(s)

            while (tokens.next()) |tagStr| {
                const tag = Tag{ tagStr[0], tagStr[1] };
                const targetValve = graph.get(tag).?;
                try valve.connections.append(Connection{ .dest = targetValve, .dist = 1 });
            }
        }

        graph.start = graph.get(Tag{ 'A', 'A' }).?;
        return graph;
    }

    fn deinit(self: Graph) void {
        for (self.valves.items) |v| {
            v.connections.deinit();
        }
        self.valves.deinit();
    }

    fn get(self: Graph, tag: Tag) ?*Valve {
        for (self.valves.items) |*v| {
            if (v.tag[0] == tag[0] and v.tag[1] == tag[1]) {
                return v;
            }
        }
        return null;
    }

    fn print(self: Graph) void {
        for (self.valves.items) |v| {
            std.log.info("{s} - {d}", .{ v.tag, v.flow });
            for (v.connections.items) |c| {
                std.log.info(" - {s}", .{c.tag});
            }
        }
    }

    fn prune(self: *Graph) void {
        for (self.valves.items) |v| {
            if (v.flow == 0) {
                // Connect each of the neighbors to eachother, and remove the connection to this valve
                for (v.connections.items) |c1| {
                    for (v.connections.items) |c2| {
                        if (c1.dest == c2.dest) continue;
                        c1.connecitons.append(c2.dest);
                    }
                }
            }
        }
    }
};

const pressureConnection = struct {
    connection: *Valve,
    distance: u64,
};

const pressureValve = struct {
    valve: *Valve,
    connections: std.ArrayList(pressureConnection),
};

const MetaGraph = struct {
    graph: *Graph,
    pressureValves: std.ArrayList(pressureValve),

    fn init(allocator: std.mem.Allocator, graph: *Graph) !MetaGraph {
        var metaGraph: MetaGraph = .{
            .graph = graph,
            .pressureValves = std.ArrayList(pressureValve).init(allocator),
        };

        // For each "normal" valve:
        for (graph.valves.items) |*v| {
            // Add it to the MetaGraph list if it has a flow greater than zero
            if (v.flow > 0) {
                try metaGraph.pressureValves.append(.{
                    .valve = v,
                    .connections = std.ArrayList(pressureConnection).init(allocator),
                });
                std.log.info("PressureValve: {s}", .{v.tag});
            }
        }

        // Populate the weighted connections
        return metaGraph;
    }

    fn deinit(self: MetaGraph) void {
        for (self.pressureValves.items) |pv| {
            pv.connections.deinit();
        }
        self.pressureValves.deinit();
    }

    fn print(self: MetaGraph) void {
        for (self.pressureValves.items) |pv| {
            std.log.info("{s} - {d}", .{ pv.valve.tag, pv.valve.flow });
            for (pv.connections.items) |c| {
                std.log.info(" - {s} -> {d}", .{ c.connection.tag, c.distance });
            }
        }
    }
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    var graph = try Graph.init(allocator, input);
    defer graph.deinit();

    var metaGraph = try MetaGraph.init(allocator, &graph);
    defer metaGraph.deinit();

    //graph.print();

    metaGraph.print();
    const part1 = getMaxPressure(&graph, graph.start, 30);

    return [2]u64{ part1, 0 };
}

// Dijkstras algorithm every time we need to evaluate the distance between two valves?
fn findDistance(start: *Valve, end: *Valve) !u64 {
    if (start == end) return 0;
    return 0;
}

fn getMaxPressure(graph: *Graph, valve: *Valve, minutesRemaining: u64) u64 {
    // Find all the possible options available right now
    // Find the maximum pressure atainable from doing it.
    // Return the return the score calculated.

    // What can we do?
    // Open this valve and then travel
    // Don't open this valve and then travel

    valve.visited += 1;

    if (minutesRemaining <= 1) {
        return 0;
    }

    var maxPressure: u64 = 0;

    if (valve.opened == true) {
        for (valve.connections.items) |c| {
            const connectionMaxPressure = getMaxPressure(graph, c.dest, minutesRemaining - c.dist);
            maxPressure = if (connectionMaxPressure > maxPressure) connectionMaxPressure else maxPressure;
        }
    } else {
        var shouldOpenNow: bool = false;

        if (valve.flow > 0) {
            valve.opened = true;
            for (valve.connections.items) |c| {
                const connectionMaxPressure = valve.flow * minutesRemaining + getMaxPressure(graph, c.dest, minutesRemaining - 1 - c.dist);
                maxPressure = if (connectionMaxPressure > maxPressure) connectionMaxPressure else maxPressure;
                shouldOpenNow = true;
            }
        }

        valve.opened = false;
        for (valve.connections.items) |c| {
            const connectionMaxPressure = getMaxPressure(graph, c.dest, minutesRemaining - c.dist);
            maxPressure = if (connectionMaxPressure > maxPressure) connectionMaxPressure else maxPressure;
            shouldOpenNow = false;
        }

        valve.opened = shouldOpenNow;
    }

    //std.log.info("{d} | {s} opened = {?} {d} : {d}", .{ minutesRemaining, valve.tag, valve.opened, valve.visited, maxPressure });

    var map: u64 = 0;
    for (graph.valves.items) |v| {
        map <<= 1;
        if (v.opened) {
            map |= 1;
        }
    }

    if (minutesRemaining > 0) {
        std.log.info("{d} | {s} opened = {?} times visited = {d}  max pressure = {d}", .{ minutesRemaining, valve.tag, valve.opened, valve.visited, maxPressure });
        //std.log.info("{b:64} - {d:20} - {s} {d:2} {d:4} {d:2}", .{ map, map, valve.tag, valve.flow, maxPressure, minutesRemaining });
    }

    return maxPressure;
}

// Okay, we have a *large* decision space, and we need to find the "best" solution.
// This sounds like a recursive, brute force type problem.
//

// I think the first thing we need is a "static evaluation" function to act as the base case for our recusrion algorithm

// fn scoreOpenNow() {
//     // mark the c
// }

// Maybe I'll have my list of valves here

//
// Lets create a list of valves with non-zero pressures
//
// create a meta-graph of valves with non-zero pressures
// This meta-graph will have connections with weights according to the distance between the two nodes.

// Can we somehow construct an "optimal" ordering of opening the valves, and then work our way through it trying to find the fastest way to get to the next valve.
// We can't do this without already knowing the time to travel to each valve.

// We can do a depth first search, by comparing each of the current options available, and picking the best.
// We can write a function which returns the score of the best option.
