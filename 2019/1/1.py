def getFuel(module):
    fuel = (module // 3) - 2
    if fuel <= 0:
        return 0
    else:
        return fuel + getFuel(fuel)

with open("input","r") as f:
    modules = [int(line.strip()) for line in f.readlines()]

fuel = sum([getFuel(module) for module in modules])

print(fuel)
