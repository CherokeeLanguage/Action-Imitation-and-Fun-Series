#!/bin/sh

set -e

Y=b
DESKEW=1
export OMP_NUM_THREADS=16

SRCCLN="src.cln.$Y"

bksize="1325x2050" #200dpi: 6.625x10.25
#bksize="1988x3075" #300dpi: 6.625x10.25
pgsize="2650x4100" #400dpi: 6.625x10.25
#pgsize="3975x6150" #600dpi: 6.625x10.25

cd "$(dirname "$0")" || exit 1

if [ ! -d "$SRCCLN" ]; then mkdir "$SRCCLN"; fi
rm "$SRCCLN"/* || true

i=0
for page in images.raw.$Y/*.ppm; do
	if [ ! -f "$page" ]; then continue; fi
	i=$(($i+1))
	#if [ "$i" != "3" ]; then continue; fi
	p="$(printf "%03d" $i)"
	echo "Processing ${page}"
	dest="$SRCCLN/$p".png
	
	tmp="$SRCCLN"/"$p"-cmyk.tiff
	black="$SRCCLN"/"$p"-k.tiff

	gm convert "$page" -filter Sinc -resize "$pgsize" -colorspace CMYK "$dest".tiff
	gm mogrify -monitor -noise 2 -noise 2 -noise 2 "$dest".tiff
	gm mogrify -set histogram-threshold 1 -normalize "$dest".tiff
	
	gm convert "$dest".tiff -channel black $black
	gm mogrify -gamma .4 "$black"
	gm mogrify -set histogram-threshold .1 -normalize "$black"
	gm mogrify -white-threshold 200 "$black"
	
	gm composite -compose CopyYellow "$black" "$black" "$tmp"
	gm composite -compose CopyCyan "$black" "$tmp" "$tmp"
	gm composite -compose CopyMagenta "$black" "$tmp" "$tmp"
	gm composite -compose Difference "$dest".tiff "$tmp" "$dest".tiff
	
	gm mogrify -monitor -fuzz 10% -noise 2 "$dest".tiff
	
	gm composite -compose CopyBlack "$black" "$dest".tiff "$dest".tiff
	
	gm convert -monitor "$dest".tiff "$dest"
	
	if [ $DESKEW = 1 ]; then mogrify -fuzz 25% -deskew 50% "$dest"; fi
	
	gm mogrify -monitor -fuzz 25% -trim "$dest"
	
	rm "$tmp"
	rm "$black"
	rm "$dest".tiff

	#svg="$SRCCLN/$p".svg
	#autotrace --color-count 32 --despeckle-level 20 \
	#		--output-format svg \
	#		--output-file "$svg" "$dest"
done

gm convert "$SRCCLN"/*.png -filter sinc -compress JPEG -quality 30 -resize "$bksize" "$SRCCLN".pdf

exit 0

	cyan="$SRCCLN"/"$p"-c.tiff
	magenta="$SRCCLN"/"$p"-m.tiff
	yellow="$SRCCLN"/"$p"-y.tiff

