#!/bin/bash

set -e
set -u

trap 'echo ERROR; read a' ERR

cd "$(dirname "$0")" || exit 1

export OMP_NUM_THREADS=4

cwd="$(pwd)"

for D in p*; do

	RES=90
	if [ "$D" = paperbook ]; then
		RES=300
	fi

	cd "${cwd}"
	if [ ! -d "$D" ]; then continue; fi
	cd "$D"
	
	echo "Creating pdfs"
	if [ ! -d "pdfs" ]; then mkdir "pdfs"; fi
	for svg in *.svg; do
		if [ ! -f "$svg" ]; then continue; fi
		pdf="$(echo "$svg"|sed 's/.svg$/.pdf/')"
		rm "pdfs/$pdf" || true
		inkscape -T -z -b white -y 1.0 -o "pdfs/${pdf}" --export-pdf-version="1.5" \
			-d ${RES} --export-area-page "${svg}"
	done

	echo "Creating pngs"
	if [ ! -d "pngs" ]; then mkdir "pngs"; fi	
	for svg in *.svg; do
		if [ ! -f "$svg" ]; then continue; fi
		png="$(echo "$svg"|sed 's/.svg$/.png/')"
		rm "pngs/$png" || true
		inkscape -z -b white -y 1.0 -o "pngs/${png}" -d ${RES} --export-area-page "${svg}"
		gm convert "pngs/${png}" -scale "50%" "pngs/half-${png}"
	done

	echo "Creating jpgs"
	if [ ! -d "jpgs" ]; then mkdir "jpgs"; fi
	p=0
	for png in pngs/*.png; do
		if [ ! -f "$png" ]; then continue; fi
		p=$(($p + 1))
		jpg="$(basename "$png"|sed 's/.png$/.jpg/')"
		gm convert -background white -flatten -quality 90 "$png" "jpgs/$jpg"
	done

	if [ "$D" = paperbook ]; then
		for png in pngs/*.png; do
			if [ ! "${png}" = "pngs/cover.png" ]; then continue; fi
			pngfront="$(echo "$png"|sed s/cover.png/frontcover.png/)"
			epubfront="$(echo "$png"|sed s/cover.png/epub-cover.png/)"
			jpgfront="$(echo "$png"|sed s/cover.png/frontcover.jpg/|sed s/pngs/jpgs/)"
			gm convert -filter Sinc "$png" -gravity NorthEast -crop 1838x2775+0+0 "$pngfront"
			gm convert -filter Sinc -quality 90 "$png" -gravity NorthEast -crop 1838x2775+0+0 "$jpgfront"
			gm convert -filter Sinc "$png" -gravity NorthEast -crop 1838x2775+0+0 -resize x1280 "$epubfront"
		done
	fi

done
echo -n "Done"
sleep 5