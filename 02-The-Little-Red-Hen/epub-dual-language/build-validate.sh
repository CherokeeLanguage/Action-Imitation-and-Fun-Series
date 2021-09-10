#!/bin/bash

F="Na-Anijoi-Sigwa"

cd "$(dirname "$0")" || exit 1

for F in *.epub; do
	if [[ "$F" == *Kindle.epub ]]; then continue; fi
	export EPUB="$(basename "$F"|sed 's/.epub$//')"
    java -jar ./bin/epubcheck-3.0.1/epubcheck-3.0.1.jar "${EPUB}"-Kindle.epub
    java -jar ./bin/epubcheck-3.0.1/epubcheck-3.0.1.jar "${EPUB}".epub
	break
done

echo "DONE $(basename "$0")"
read a
