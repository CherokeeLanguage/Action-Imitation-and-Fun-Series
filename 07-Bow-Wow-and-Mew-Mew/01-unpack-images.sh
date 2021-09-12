#!/bin/bash

X="Bow_wow_and_mew_mew.pdf"
D="images.raw"
cd "$(dirname "$0")" || exit 1

if [ ! -d "$D" ]; then mkdir "$D"; fi
for x in "$D"/*jpg "$D"/*png "$D"/*ppm "$D"/*pbm; do
	if [ ! -f "$x" ]; then continue; fi
	rm -rf "$x"
done

pdfimages -j -p -q "$X" "$D"/image

for x in "$D"/*; do
	if [ ! -f "$x" ]; then continue; fi
	e="$(basename "$x"|cut -f 2 -d '.')"
	if [ "$e" = "pbm" ]; then
		rm "$x"
		continue
	fi
	echo "$x"
	y="$(md5sum "$x"|cut -f 1 -d ' ')"
	if [ "$y" = "ea9c4d4d57a1993e1fcc119576356b1f" ]; then
		rm "$x"
		continue
	fi
	if [ "$y" = "c63861120bef1e13a7910f180cf41bdf" ]; then
		rm "$x"
		continue
	fi
	if [ "$y"  = "38f9e5ad0a4b058177f52da9769204b2" ]; then
		rm "$x"
		continue
	fi
done

echo "Done."
read a

