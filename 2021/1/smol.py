#! /usr/bin/python

import sys

inputFile = sys.argv[1]

with open(inputFile,'r') as file:
	lines = [int(line.strip()) for line in file.readlines()]

count = 0

prevDepth = lines[0]

for depth in lines[1:]:
	if depth - prevDepth > 0:
		count += 1
	prevDepth = depth

print(count)
