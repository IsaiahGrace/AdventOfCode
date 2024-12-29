import numpy as np
from rich import print


def solve(puzzle):
    reports = list()

    for l in puzzle.splitlines():
        reports.append(np.fromiter((int(n) for n in l.split(" ")), np.int8))

    safe_reports = 0
    for report in reports:
        diff = np.diff(report)
        abs_diff = np.abs(diff)
        signs = np.sign(diff)

        if np.max(signs) != np.min(signs):
            continue

        if np.max(abs_diff) > 3:
            continue

        safe_reports += 1

    return safe_reports
