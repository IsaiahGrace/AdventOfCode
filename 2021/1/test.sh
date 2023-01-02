#! /bin/bash

part1=$(./solution.py input)
if [[ $part1 == "1688" ]]; then
	echo "Part1 -- OK"
else
	echo "Part1 -- FAIL"
	exit 1
fi

part1smol=$(./smol.py input)
if [[ $part1smol == "1688" ]]; then
	echo "Part1smol -- OK"
else
	echo "Part1smol -- FAIL"
	exit 1
fi

part2=$(./part2.py input)
if [[ $part2 == "1728" ]]; then
	echo "Part2 -- OK"
else
	echo "Part2 -- FAIL"
	exit 1
fi
