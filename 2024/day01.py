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

    part1 = sum(abs(l - r) for l, r in zip(left, right))

    freq = dict()
    for n in right:
        freq[n] = freq.get(n, 0) + 1

    part2 = sum(n * freq.get(n, 0) for n in left)
    return (part1, part2)
