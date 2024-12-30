from rich import print

directions = {
    "N": (-1, 0),
    "NE": (-1, 1),
    "E": (0, 1),
    "SE": (1, 1),
    "S": (1, 0),
    "SW": (1, -1),
    "W": (0, -1),
    "NW": (-1, -1),
}


def X(puzzle, row, col):
    if puzzle[row][col] != "X":
        return 0
    return sum(map(lambda d: M(puzzle, row, col, d), directions.keys()))


def M(puzzle, row, col, direction):
    row += directions[direction][0]
    col += directions[direction][1]
    if row < 0 or col < 0:
        return 0
    try:
        if puzzle[row][col] != "M":
            return 0
        return A(puzzle, row, col, direction)
    except IndexError:
        return 0


def A(puzzle, row, col, direction):
    row += directions[direction][0]
    col += directions[direction][1]
    if row < 0 or col < 0:
        return 0
    if puzzle[row][col] != "A":
        return 0
    return S(puzzle, row, col, direction)


def S(puzzle, row, col, direction):
    row += directions[direction][0]
    col += directions[direction][1]
    if row < 0 or col < 0:
        return 0
    if puzzle[row][col] != "S":
        return 0
    return 1


def XMAS(puzzle, row, col):
    if puzzle[row][col] != "A":
        return 0
    if row < 1 or col < 1:
        return 0
    if row > len(puzzle) - 2 or col > len(puzzle[row]) - 2:
        return 0

    NESW = False
    NWSE = False

    NE = puzzle[row - 1][col + 1]
    NW = puzzle[row - 1][col - 1]
    SE = puzzle[row + 1][col + 1]
    SW = puzzle[row + 1][col - 1]

    if NE == "M" and SW == "S" or NE == "S" and SW == "M":
        NESW = True

    if NW == "M" and SE == "S" or NW == "S" and SE == "M":
        NWSE = True

    if NESW and NWSE:
        return 1
    return 0


def solve(puzzle):
    puzzle = [list(line) for line in puzzle.splitlines()]
    part1 = 0
    part2 = 0
    for row, r in enumerate(puzzle):
        for col, _ in enumerate(r):
            part1 += X(puzzle, row, col)
            part2 += XMAS(puzzle, row, col)

    return (part1, part2)
