#!/bin/sh

if ! [ -f "credentials.lua" ] ; then
	cp "credentials_sample.lua" "credentials.lua"
fi

luatool.py -v -p /dev/ttyUSB0 -b 115200    -f init.lua
luatool.py -v -p /dev/ttyUSB0 -b 115200 -c -f credentials.lua
luatool.py -v -p /dev/ttyUSB0 -b 115200 -c -f my_init.lua
luatool.py -v -p /dev/ttyUSB0 -b 115200 -c -f application.lua
