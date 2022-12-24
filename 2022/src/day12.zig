const std = @import("std");

// Looks like it's time for Dijkstra's algorithm again!
// Actually, I'd like to take a shot at A*

// We'll have to create our graph data structure carefully, so that we can define neighbors
// We can use the coordinate system for our distance approximation function.
// What will the data structure look like?
// We could create a 2d array of nodes, but not all neighbors are connected...

// The Coord type can act like a pointer to a Node
const Coord = struct {
    row: usize,
    col: usize,
};

const Node = struct {
    height: u8,
    cost: ?usize,
};

const Graph = struct {
    nodes: [][]Node,
    start: Coord,
    end: Coord,
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    var graph: Graph = try parseGraph(allocator, input);
    defer {
        for (graph.nodes) |row| {
            allocator.free(row);
        }
        allocator.free(graph.nodes);
    }

    const part1 = try solveP1(allocator, graph);
    // Reset the costs in the graph, so we can use it for part 2
    for (graph.nodes) |*row| {
        for (row.*) |*node| {
            node.*.cost = null;
        }
    }
    const part2 = try solveP2(allocator, graph);

    return [2]u64{ part1, part2 };
}

fn solveP2(allocator: std.mem.Allocator, graph: Graph) !u64 {
    // Part 2 asks us to find the closest 'a' tile to the end to make the best hiking route.
    // We'll work backwards looking for an 'a' tile starting at 'E'.
    // But the node connection rules are different in the reverse direction.
    var closestNodes = std.PriorityDequeue(Coord, Graph, compareNodes).init(allocator, graph);
    defer closestNodes.deinit();

    // Add the ending position's neighbors to closestNodes
    const endNeighbors = try findReverseNeighbors(graph, graph.end);
    for (endNeighbors) |node| {
        if (node) |n| {
            graph.nodes[n.row][n.col].cost = 1;
            try closestNodes.add(n);
        }
    }

    while (true) {
        // Take the closest node
        const closest: Coord = closestNodes.removeMinOrNull() orelse {
            return error.CouldNotFindEnd;
        };

        // check if we're at an 'a' tile
        if (graph.nodes[closest.row][closest.col].height == 'a') {
            return graph.nodes[closest.row][closest.col].cost.?;
        }

        // Get the neighbors of closest
        const neighbors = try findReverseNeighbors(graph, closest);

        // calculate cost and update neighbors
        const neighborCost = graph.nodes[closest.row][closest.col].cost.? + 1;
        for (neighbors) |neighbor| {
            if (neighbor) |n| {
                if (graph.nodes[n.row][n.col].cost == null) {
                    graph.nodes[n.row][n.col].cost = neighborCost;

                    // Add neighbors of this node to closestNodes
                    try closestNodes.add(n);
                } else {
                    std.debug.assert(graph.nodes[n.row][n.col].cost.? <= neighborCost);
                }
            }
        }
    }
}

fn findReverseNeighbors(graph: Graph, x: Coord) ![4]?Coord {
    var neighbors = [1]?Coord{null} ** 4;
    const xHeight = @as(i32, graph.nodes[x.row][x.col].height);

    // N
    if (x.row > 0) {
        const nHeight = @as(i32, graph.nodes[x.row - 1][x.col].height);
        if (xHeight <= nHeight or xHeight - 1 == nHeight) {
            neighbors[0] = Coord{
                .row = x.row - 1,
                .col = x.col,
            };
        }
    }

    // S
    if ((x.row + 1) < graph.nodes.len) {
        const sHeight = @as(i32, graph.nodes[x.row + 1][x.col].height);
        if (xHeight <= sHeight or xHeight - 1 == sHeight) {
            neighbors[1] = Coord{
                .row = x.row + 1,
                .col = x.col,
            };
        }
    }

    // E
    if ((x.col + 1) < graph.nodes[graph.start.row].len) {
        const eHeight = @as(i32, graph.nodes[x.row][x.col + 1].height);
        if (xHeight <= eHeight or xHeight - 1 == eHeight) {
            neighbors[2] = Coord{
                .row = x.row,
                .col = x.col + 1,
            };
        }
    }

    // W
    if (x.col > 0) {
        const wHeight = @as(i32, graph.nodes[x.row][x.col - 1].height);
        if (xHeight <= wHeight or xHeight - 1 == wHeight) {
            neighbors[3] = Coord{
                .row = x.row,
                .col = x.col - 1,
            };
        }
    }

    return neighbors;
}

fn solveP1(allocator: std.mem.Allocator, graph: Graph) !u64 {
    var closestNodes = std.PriorityDequeue(Coord, Graph, compareNodes).init(allocator, graph);
    defer closestNodes.deinit();

    // Add the starting position's neighbors to closestNodes
    const startNeighbors = try findNeighbors(graph, graph.start);
    for (startNeighbors) |node| {
        if (node) |n| {
            graph.nodes[n.row][n.col].cost = 1;
            try closestNodes.add(n);
        }
    }

    while (true) {
        // Take the closest node
        const closest: Coord = closestNodes.removeMinOrNull() orelse {
            return error.CouldNotFindEnd;
        };

        // check if we're at the end
        if (closest.row == graph.end.row and closest.col == graph.end.col) {
            return graph.nodes[closest.row][closest.col].cost.?;
        }

        // Get the neighbors of closest
        const neighbors = try findNeighbors(graph, closest);

        // calculate cost and update neighbors
        const neighborCost = graph.nodes[closest.row][closest.col].cost.? + 1;
        for (neighbors) |neighbor| {
            if (neighbor) |n| {
                if (graph.nodes[n.row][n.col].cost == null) {
                    graph.nodes[n.row][n.col].cost = neighborCost;

                    // Add neighbors of this node to closestNodes
                    try closestNodes.add(n);
                } else {
                    std.debug.assert(graph.nodes[n.row][n.col].cost.? <= neighborCost);
                }
            }
        }
    }
}

// Returns up to four neighbors of the node referenced by x
fn findNeighbors(graph: Graph, x: Coord) ![4]?Coord {
    var neighbors = [1]?Coord{null} ** 4;
    const xHeight = @as(i32, graph.nodes[x.row][x.col].height);

    // N
    if (x.row > 0) {
        const nHeight = @as(i32, graph.nodes[x.row - 1][x.col].height);
        if (xHeight >= nHeight or xHeight + 1 == nHeight) {
            neighbors[0] = Coord{
                .row = x.row - 1,
                .col = x.col,
            };
        }
    }

    // S
    if ((x.row + 1) < graph.nodes.len) {
        const sHeight = @as(i32, graph.nodes[x.row + 1][x.col].height);
        if (xHeight >= sHeight or xHeight + 1 == sHeight) {
            neighbors[1] = Coord{
                .row = x.row + 1,
                .col = x.col,
            };
        }
    }

    // E
    if ((x.col + 1) < graph.nodes[graph.start.row].len) {
        const eHeight = @as(i32, graph.nodes[x.row][x.col + 1].height);
        if (xHeight >= eHeight or xHeight + 1 == eHeight) {
            neighbors[2] = Coord{
                .row = x.row,
                .col = x.col + 1,
            };
        }
    }

    // W
    if (x.col > 0) {
        const wHeight = @as(i32, graph.nodes[x.row][x.col - 1].height);
        if (xHeight >= wHeight or xHeight + 1 == wHeight) {
            neighbors[3] = Coord{
                .row = x.row,
                .col = x.col - 1,
            };
        }
    }

    return neighbors;
}

fn compareNodes(graph: Graph, a: Coord, b: Coord) std.math.Order {
    const aCost = graph.nodes[a.row][a.col].cost.?;
    const bCost = graph.nodes[b.row][b.col].cost.?;
    return std.math.order(aCost, bCost);
}

fn parseGraph(allocator: std.mem.Allocator, input: []u8) !Graph {
    var graph: Graph = undefined;

    var lines = std.mem.tokenize(u8, input, "\n");

    // Find the number of rows and collumns:
    const columns = lines.next().?.len;
    const rows = rows: {
        var r: usize = 1;
        while (lines.next() != null) {
            r += 1;
        }
        break :rows r;
    };
    lines.reset();

    // Allocate the 2D array of Nodes
    graph.nodes = try allocator.alloc([]Node, rows);
    errdefer allocator.free(graph.nodes);

    var r: usize = 0;
    while (r < rows) : (r += 1) {
        graph.nodes[r] = try allocator.alloc(Node, columns);
        errdefer allocator.free(graph.nodes[r]);
    }

    // Parse the input into the graph:
    var foundStart = false;
    var foundEnd = false;
    r = 0;
    while (lines.next()) |line| : (r += 1) {
        var c: usize = 0;
        while (c < line.len) : (c += 1) {
            if ((line[c] < 'a' or line[c] > 'z') and (line[c] < 'A' or line[c] > 'Z')) {
                return error.InvalidPuzzleInput;
            }
            var height: u8 = undefined;
            var cost: ?usize = null;
            if (line[c] == 'S') {
                foundStart = true;
                height = 'a';
                cost = 0;
                graph.start = Coord{
                    .row = r,
                    .col = c,
                };
            } else if (line[c] == 'E') {
                foundEnd = true;
                height = 'z';
                graph.end = Coord{
                    .row = r,
                    .col = c,
                };
            } else {
                height = line[c];
            }
            graph.nodes[r][c] = Node{
                .height = height,
                .cost = cost,
            };
        }
    }

    if (!(foundStart and foundEnd)) {
        return error.InvalidPuzzleInput;
    }

    return graph;
}
