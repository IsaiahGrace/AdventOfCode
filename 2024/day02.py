import numpy as np
from rich import print


def safe(report):
    diff = np.diff(report)
    signs = np.sign(diff)
    abs_diff = np.abs(diff)

    if diff[0] == 0:
        return 0

    if np.max(signs) != np.min(signs):
        return 0

    if np.max(abs_diff) > 3:
        return 0

    return 1


def solve(puzzle):
    reports = list()

    for line in puzzle.splitlines():
        reports.append(np.fromiter((int(n) for n in line.split(" ")), np.int8))

    unsafe_reports_part_1 = list(filter(lambda x: not safe(x), reports))
    safe_reports_part1 = len(reports) - len(unsafe_reports_part_1)

    safe_reports_part2 = 0
    for report in unsafe_reports_part_1:
        for i in range(len(report)):
            if safe(np.delete(report, i)):
                safe_reports_part2 += 1
                break

    safe_reports_part2 += safe_reports_part1

    return (safe_reports_part1, safe_reports_part2)
