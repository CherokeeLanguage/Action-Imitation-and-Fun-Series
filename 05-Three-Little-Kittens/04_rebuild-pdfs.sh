#!/bin/bash
set -e

cd "$(dirname "$0")"
F="Na-Anijoi-Wesa-Anida"

Z="$(pwd)"

lyx -e pdf4 "${F}".lyx
lyx -e pdf4 "${F}"-embedded-cover.lyx

echo "" | ps2pdf -sPAPERSIZE=letter - artwork/clipart/pdfs/blank.pdf

pdftk A=artwork/clipart/pdfs/draft.pdf B=artwork/clipart/pdfs/blank.pdf cat A B output artwork/clipart/pdfs/draftblank.pdf

pdftk "${F}"-embedded-cover.pdf stamp artwork/clipart/pdfs/draft.pdf output "${F}"-draft.pdf

echo "DONE."

sleep 1

exit 0
