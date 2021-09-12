#!/bin/bash

cd "$(dirname "$0")" || exit 1

export OMP_NUM_THREADS=4

cwd="$(pwd)"

for D in src.xcf; do

	cd "${cwd}"
	if [ ! -d "$D" ]; then continue; fi
	cd "$D"
	
	echo "Creating jpgs"
	if [ ! -f "jpgs" ]; then mkdir "jpgs"; fi
	p=0
	for xcf in *.xcf; do
		if [ ! -f "$xcf" ]; then continue; fi
		p=$(($p + 1))
		jpg="$(basename "$xcf"|sed 's/.xcf$/.jpg/')"
		gm convert -background white -flatten -quality 30 "$xcf" -gravity center -background white -extent 2650x "jpgs/$jpg"
	done

done
echo -n "Done"
sleep 1



