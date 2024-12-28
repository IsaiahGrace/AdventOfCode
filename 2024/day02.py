import numpy as np
from rich import print

reports = list()

with open("02/input") as f:
    for l in f.readlines():
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

print(safe_reports)
