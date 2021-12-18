#! /usr/bin/python

import sys

inputFile = sys.argv[1]

with open(inputFile,'r') as file:
	lines = [int(line.strip()) for line in file.readlines()]

length = len(lines)

numIncreased = 0

for i in range(1,length):
	difference = lines[i] - lines[i-1]
	if difference > 0:
		numIncreased += 1

print(numIncreased)
