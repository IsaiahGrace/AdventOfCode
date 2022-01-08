#! /bin/bash

if [[ -z $1 ]]; then
	echo Please specify an input text file as an argument
	exit 1
fi

cat $1 | sed 's/.*|//; s/ /  /g' | grep -Eo ' ([^ ]{2}|[^ ]{3}|[^ ]{4}|[^ ]{7})( |$)' | wc -l
