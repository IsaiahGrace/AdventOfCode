from rich import print
import re


def solve(puzzle):
    mem = "".join(line.strip() for line in puzzle.splitlines())

    mul = re.compile(r"mul\((\d{1,3}),(\d{1,3})\)")
    do = re.compile(r"do\(\)")
    dont = re.compile(r"don't\(\)")

    part1 = 0
    tokens = list()
    for m in mul.finditer(mem):
        product = int(m[1]) * int(m[2])
        part1 += product
        tokens.append((m.span()[0], product))

    for m in do.finditer(mem):
        tokens.append((m.span()[0], True))

    for m in dont.finditer(mem):
        tokens.append((m.span()[0], False))

    tokens.sort(key=lambda x: x[0])

    part2 = 0
    enabled = True
    for t in tokens:
        if type(t[1]) == bool:
            enabled = t[1]
        elif enabled:
            part2 += t[1]

    return (part1, part2)
