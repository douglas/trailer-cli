#!/bin/sh

echo "*** Cleaning"
swift package reset

echo "*** Building"
if [ `uname -s` = "Linux" ] ; then
	swift build -c release -Xswiftc -Ounchecked -Xswiftc -whole-module-optimization
else
	swift build -c release -Xswiftc -static-stdlib -Xswiftc -Ounchecked -Xswiftc -whole-module-optimization
fi

if [ $? -eq 0 ]; then
	SRC="$(swift build -c release --show-bin-path)/trailer"
	echo "*** Stripping symbols"
	strip $SRC
	echo "*** Installing 'trailer' to /usr/local/bin, please enter your sudo password if needed"
	sudo install $SRC /usr/local/bin/trailer
	echo "*** Cleaning Up"
	swift package reset
	echo "*** Done"
else
	echo
	echo "*** Build failed, ensure you are using Swift 4.x on the command line"
fi
