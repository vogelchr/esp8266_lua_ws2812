#!/bin/sh

if ! [ -f "credentials.lua" ] ; then
	cp "credentials_sample.lua" "credentials.lua"
fi

if [ -n "$1" ] ; then
	appname="$1"
else
	appname="1d"
fi

if ! [ -f "application_${appname}.lua" ] ; then
	echo "Cannot upload, application_${appname}.lua is missing!" >&2
	exit 1
fi

luatool_arg="-v -p /dev/ttyUSB0 -b 115200 --delay 0.1"

luatool.py $luatool_arg -w
luatool.py $luatool_arg       -f init.lua
luatool.py $luatool_arg -c    -f credentials.lua
luatool.py $luatool_arg -c    -f my_init.lua
luatool.py $luatool_arg -c    -f "application_${appname}.lua" -t application.lua
