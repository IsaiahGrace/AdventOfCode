#! /usr/bin/python

import sys

inputFile = sys.argv[1]

with open(inputFile,'r') as file:
	lines = [int(line.strip()) for line in file.readlines()]

length = len(lines)
windows = []

for i in range(2,length):
	windows.append(lines[i] + lines[i-1] + lines[i-2])

length = len(windows)
numIncreased = 0
for i in range(1,length):
	difference = windows[i] - windows[i-1]
	if difference > 0:
		numIncreased += 1

print(numIncreased)
