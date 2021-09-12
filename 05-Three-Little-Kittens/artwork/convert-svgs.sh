#!/bin/bash

cd "$(dirname "$0")" || exit 1

export OMP_NUM_THREADS=4

cwd="$(pwd)"

PT_WIDTH=441
PT_HEIGHT=666
CROP_WIDTH=1838
CROP_HEIGHT=2775

for D in *; do

	RES=90
	if [ "$D" = paperbook ]; then
		RES=300
	fi

	cd "${cwd}"
	if [ ! -d "$D" ]; then continue; fi
	cd "$D"
	
	echo "Creating pdfs"
	if [ -d "pdfs" ]; then rm -rf "pdfs"; fi
	mkdir pdfs
	for svg in *.svg; do
		if [ ! -f "$svg" ]; then continue; fi
		pdf="$(echo "$svg"|sed 's/.svg$/.pdf/')"
		if [ -f "pdfs/$pdf" ]; then rm "pdfs/$pdf"; fi
		inkscape -T -z -b=white -y=1.0 -A "pdfs/${pdf}" --export-pdf-version="1.5" \
			-d ${RES} --export-area-page "${svg}"
	done

	echo "Creating pngs"
	if [ -d "pngs" ]; then rm -rf "pngs"; fi	
	mkdir "pngs"
	for svg in *.svg; do
		if [ ! -f "$svg" ]; then continue; fi
		png="$(echo "$svg"|sed 's/.svg$/.png/')"
		rm "pngs/$png"
		inkscape -z -b=white -y=1.0 -e "pngs/${png}" -d ${RES} --export-area-page "${svg}"
		convert "pngs/${png}" -scale "50%" "pngs/half-${png}"
	done

	echo "Creating jpgs"
	if [ -d "jpgs" ]; then rm -rf "jpgs"; fi
	mkdir "jpgs"
	p=0
	for png in pngs/*.png; do
		if [ ! -f "$png" ]; then continue; fi
		p=$(($p + 1))
		jpg="$(basename "$png"|sed 's/.png$/.jpg/')"
		gm convert -background white -flatten $T -quality 90 "$png" "jpgs/$jpg"
	done

	if [ "$D" = paperbook ]; then
		for png in pngs/*.png; do
			if [[ "${png}" == "pngs/half"* ]]; then continue; fi
			if [[ "${png}" != *"cover.png" ]]; then echo "[x] ${png}"; continue; fi
			pngfront="$(echo "$png"|sed s/cover.png/frontcover.png/)"
			pngback="$(echo "$png"|sed s/cover.png/backcover.png/)"
			epubfront="$(echo "$png"|sed s/cover.png/epub-cover.png/)"
			jpgfront="$(echo "$png"|sed s/cover.png/frontcover.jpg/|sed s/pngs/jpgs/)"
			gm convert -filter Sinc "$png" -gravity NorthEast -crop ${CROP_WIDTH}x${CROP_HEIGHT}+0+0 "$pngfront"
			gm convert -filter Sinc "$png" -gravity NorthWest -crop ${CROP_WIDTH}x${CROP_HEIGHT}+0+0 "$pngback"
			gm convert -filter Sinc -quality 90 "$png" -gravity NorthEast -crop ${CROP_WIDTH}x${CROP_HEIGHT}+0+0 "$jpgfront"
			gm convert -filter Sinc "$png" -gravity NorthEast -crop ${CROP_WIDTH}x${CROP_HEIGHT}+0+0 -resize x1280 "$epubfront"
		done
	fi
	

done
echo -n "Done"
sleep 1



