from rich import print


def solve(puzzle):
    left = list()
    right = list()

    for line in puzzle.splitlines():
        loc = line.strip().split()
        left.append(int(loc[0]))
        right.append(int(loc[1]))

    left.sort()
    right.sort()

    distances = sum(abs(l - r) for l, r in zip(left, right))
    return distances
