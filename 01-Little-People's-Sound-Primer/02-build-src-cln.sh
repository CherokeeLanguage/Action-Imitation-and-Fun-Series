#!/bin/sh

export OMP_NUM_THREADS=4

bksize="1325x2050" #200dpi: 6.625x10.25
#bksize="1988x3075" #300dpi: 6.625x10.25
pgsize="2650x4100" #400dpi: 6.625x10.25
#pgsize="3975x6150" #600dpi: 6.625x10.25

cd "$(dirname "$0")" || exit 1

if [ ! -d src.cln ]; then mkdir src.cln; fi
rm src.cln/*

i=0
for page in images.raw/*.ppm; do
	if [ ! -f "$page" ]; then continue; fi
	i=$(($i+1))
	#if [ "$i" != "3" ]; then continue; fi
	p="$(printf "%03d" $i)"
	echo "Processing ${page}"
	dest="src.cln/$p".png
	gm convert "$page" -filter Sinc -resize "$pgsize" -colorspace CMYK "$dest".tiff
	gm mogrify -set histogram-threshold 5 -normalize "$dest".tiff
	cyan=src.cln/"$p"-c.tiff
	magenta=src.cln/"$p"-m.tiff
	yellow=src.cln/"$p"-y.tiff
	black=src.cln/"$p"-k.tiff
	tmp=src.cln/"$p"-cmyk.tiff
	gm convert "$dest".tiff -channel black $black &
	gm convert "$dest".tiff -channel cyan $cyan &
	gm convert "$dest".tiff -channel magenta $magenta &
	gm convert "$dest".tiff -channel yellow $yellow &
	wait
	if [ $? != 0 ]; then exit -1; fi

	rm "$dest".tiff
	(
		echo " - ${black}"
		gm mogrify -set histogram-threshold 3 -normalize "$black"
		gm mogrify -gamma .6 "$black"
		gm mogrify -median 2 "$black"
		cp "$black" "$black"-x
		
		gm mogrify -white-threshold 200 "$black"
		gm mogrify -set histogram-threshold 3 -normalize "$black"-x
		gm mogrify -blur 0x3 "$black"-x
		gm mogrify -white-threshold 200 "$black"-x
	) &
	wait
	if [ $? != 0 ]; then exit -1; fi
	for c in "$cyan" "$magenta" "$yellow"; do
		(
		echo " - ${c}"
		gm mogrify -black-threshold 30 "$c"
		gm composite -compose Minus "$black"-x "$c" "$c"
		#gm mogrify -median 4 "$c"
		gm mogrify -blur 0x3 "$c"
		gm mogrify -gamma .9 "$c"
		#gm mogrify -set histogram-threshold 3 -normalize "$c"
		) &
	done
	wait
	if [ $? != 0 ]; then exit -1; fi

	(
	echo " - composite and convert"
	rm "$black"-x
	gm composite -compose CopyYellow "$yellow" "$magenta" "$tmp"
	rm "$yellow"
	rm "$magenta"
	gm composite -compose CopyBlack "$black" "$tmp" "$tmp"
	rm "$black"
	gm composite -compose CopyCyan "$cyan" "$tmp" "$tmp"
	rm "$cyan"
	#gm convert "$tmp" -normalize "$dest"
	gm convert "$tmp" "$dest"
	rm "$tmp"
	) &
done

wait
if [ $? != 0 ]; then exit -1; fi

gm convert src.cln/*.png -filter sinc -compress JPEG -quality 30 -resize "$bksize" src-cln.pdf


