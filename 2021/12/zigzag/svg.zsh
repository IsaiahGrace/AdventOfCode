#! /bin/zsh

if [[ "$1" == "" ]]; then
	echo "Please provide a file path as an argument"
	exit 1
fi

if [[ ! -f "$1" ]]; then	
	echo "Please ensure that the argument is a valid file path"
	exit 1
fi

cat $1 | sed -e "s/^/  /" -e "s/$/ [dir=\"both\"]/" -e "1i\digraph {" -e "\$a}" -e "s/-/ -> /" | dot -Tsvg > "$1.svg"

xdg-open $1.svg

