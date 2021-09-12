#!/bin/bash
set -e
cd "$(dirname "$0")"
Z="$(pwd)"
DESTDIR="epub"

cd /home/mjoyner/git/Lyx2EPub/Lyx2EPub
gradle :fatjar
lyx2epub='/home/mjoyner/git/Lyx2EPub/Lyx2EPub/build/libs/lyx2epub.jar'

cd "$Z"
if [ ! -d "${DESTDIR}" ]; then mkdir "${DESTDIR}"; fi
if [ ! -d "${DESTDIR}"/image-tmp ]; then mkdir "${DESTDIR}"/image-tmp; fi
java -jar "${lyx2epub}" --settings "${DESTDIR}"/settings.json
if [ $? != 0 ]; then
	echo "ERROR."
	read a;
	exit 1
fi
cd "${DESTDIR}"

for F in *.epub; do
	if [[ "$F" == *"Kindle.epub" ]]; then echo "skipping: $F"; continue; fi
	echo "\tRecompressing: $F"
	export EPUB="$(basename "$F"|sed 's/.epub$//')"
	echo "Processing $EPUB"
	
	#unzip "$F" -d "$EPUB"-unpacked

	#recompress jpegs
	unzip "${EPUB}".epub '*.jpg' -d "tmp.$$"
	for x in "tmp.$$"/*/Images/*.jpg; do
		echo "$x"
		gm mogrify -quality 30 "$x"
	done
	cd "tmp.$$"
	zip -9 -r  ../"${EPUB}".epub . -i "*.jpg"
	zip -9 -r  ../"${EPUB}"-Kindle.epub . -i "*.jpg"
	cd ..
	rm -rfv "tmp.$$"

	#recompress pngs
	unzip "${EPUB}".epub '*.png' -d "tmp.$$"
	for x in "tmp.$$"/*/Images/*.png; do
		pngcrush "$x" "$x".tmp
		mv "$x".tmp "$x"
	done
	cd "tmp.$$"
	zip -9 -r  ../"${EPUB}".epub . -i "*.png"
	zip -9 -r  ../"${EPUB}"-Kindle.epub . -i "*.png"
	cd ..
	rm -rfv "tmp.$$"

	#update nook
	if [ -d "/media/mjoyner/nook/my documents" ]; then
		rm -v "/media/mjoyner/nook/my documents/${EPUB}".epub || true
		sync
		cp -v "${EPUB}".epub "/media/mjoyner/nook/my documents/."
		sync
	fi	
	
	#copy sync
	DEST="/home/mjoyner/Sync/Cherokee/CherokeeReferenceMaterial/ᎹᎦᎵ-MISC/"
	if [ ! -d "${DEST}" ]; then mkdir -p "${DEST}"; fi
	cp "${EPUB}".epub "${DEST}"/.

done

