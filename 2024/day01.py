from rich import print

left = list()
right = list()

with open("01/input") as f:
    for line in f.readlines():
        loc = line.strip().split()
        left.append(int(loc[0]))
        right.append(int(loc[1]))

left.sort()
right.sort()

distances = sum(abs(l-r) for l,r in zip(left,right))
print(distances)
