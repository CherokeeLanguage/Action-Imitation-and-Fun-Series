#!/bin/bash

cd "$(dirname "$0")" || exit 1

TRACE_COLORS=64

export OMP_NUM_THREADS=4

pgsize="2650x4100"

cwd="$(pwd)"
for SUB in a b; do 
	DEST="$cwd/jpgs-${SUB}"
	if [ -d "${DEST}" ]; then rm -rf "${DEST}"; fi
	mkdir "${DEST}"
	for D in src.xcf-${SUB}; do
		if [ ! -d "$D" ]; then continue; fi
		echo "Creating jpgs"
		p=0
		for xcf in "$D"/*.xcf; do
			if [ ! -f "$xcf" ]; then continue; fi
			p=$(($p + 1))
			jpg="${DEST}/$(basename "$xcf"|sed 's/.xcf$/.jpg/')"
			pdf="${DEST}/$(basename "$xcf"|sed 's/.xcf$/.pdf/')"
			png="${DEST}/$(basename "$xcf"|sed 's/.xcf$/.png/')"
			gm convert -background white -flatten -quality 30 "$xcf" \
				-gravity center -background white \
				-filter Sinc -resize "$pgsize" \
				-extent 2650x "${jpg}"
			#gm convert -background white -flatten -quality 30 "$xcf" \
			#	-gravity center -background white -extent 2650x "${png}"
			#autotrace --color-count "$TRACE_COLORS" \
			#	--despeckle-level 20 \
			#	--output-format pdf \
			#	--output-file "${pdf}" "${png}"
			#rm "${png}"
		done
	done
done

echo -n "Done"
sleep 1
