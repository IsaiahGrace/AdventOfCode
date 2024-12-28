const std = @import("std");

const Report = std.ArrayList(u8);

pub fn solve(allocator: std.mem.Allocator, input: []u8) ![2]u64 {
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    var reports = std.ArrayList(Report).init(allocator);
    defer {
        for (reports.items) |report| {
            report.deinit();
        }
        reports.deinit();
    }

    while (lines.next()) |line| {
        var report = Report.init(allocator);
        var levels = std.mem.tokenizeAny(u8, line, " ");
        while (levels.next()) |level| {
            try report.append(try std.fmt.parseInt(u8, level, 10));
        }
        try reports.append(report);
    }

    // var safe_reports: u64 = 0;
    // for (reports.items) |report| {
    //     var safe: bool = true;
    //     var step: i8 = 0;
    //     for (1..report.items.len) |i| {
    //         const prev = report.items[i - 1];
    //         const curr = report.items[i];
    //     }
    // }

    return [2]u64{ 0, 0 };
}
