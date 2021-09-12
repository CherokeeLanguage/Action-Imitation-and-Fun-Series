#!/bin/bash

D="images.raw"
cd "$(dirname "$0")" || exit 1

if [ ! -d "$D" ]; then mkdir "$D"; fi
for x in "$D"/*jpg "$D"/*png "$D"/*ppm "$D"/*pbm; do
	if [ ! -f "$x" ]; then continue; fi
	rm -rf "$x"
done

X1="Three_Little_Kittens.pdf"
X2="Three_little_kittens_and_chicken_little.pdf"

pdfimages -j -p -q "$X1" "$D"/a
pdfimages -j -p -q "$X2" "$D"/b

cd "$D" || exit 1

for x in *; do
	if [ ! -f "$x" ]; then continue; fi
	y="$(echo "$x"|sed 's/^\(.\)-\(.*\)\(....\)/\2-\1\3/')"
	mv -v "$x" "$y"
done

for x in *; do
	if [ ! -f "$x" ]; then continue; fi
	e="$(basename "$x"|cut -f 2 -d '.')"
	if [ "$e" != "pbm" ]; then
		continue
	fi
	y=pbm-"$x"
	mv -v "$x" "$y"
done

for x in *; do
	if [ ! -f "$x" ]; then continue; fi
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
	echo "$x"
done

echo "Done."
read a

