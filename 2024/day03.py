import re

with open("03/input") as f:
    mem = "".join(line.strip() for line in f.readlines())

mul = re.compile(r"mul\((\d{1,3}),(\d{1,3})\)")

part1 = sum(int(m[1]) * int(m[2]) for m in mul.finditer(mem))
print(part1)
