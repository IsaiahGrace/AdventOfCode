#! /bin/bash

signal=0

cat phases | while read phase; do
	signal=$(echo $phase$'\n'$signal$ | build/amps input)
	echo $phase $signal
done
