#!/bin/sh

cd "$(dirname "$0")" || exit 1

Z="$(pwd)";
cd /home/mjoyner/git/Lyx2EPub/Lyx2EPub
gradle :fatjar
cd "$Z"
cp '/home/mjoyner/git/Lyx2EPub/Lyx2EPub/build/libs/Lyx2EPub-1.0-capsule.jar' .
chmod +x Lyx2EPub-1.0-capsule.jar
java -jar Lyx2EPub-1.0-capsule.jar 
if [ $? != 0 ]; then
	echo "ERROR."
	read a;
	exit 1
fi
cd epub
bash 00_do-all.sh
