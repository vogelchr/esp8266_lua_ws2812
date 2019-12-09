#!/usr/bin/python
import time
import argparse
import sys
import socket

# pipe in from ffmpeg -f rawvideo -c:v rawvideo -vf scale=8:8 -pix_fmt rgb24 ...

def reshuffle(a) :
    ret = bytearray(a)
    for row in range(1,8,2) :
        for col in range(8) :
            srcix = 24*row + 3*col
            dstix = 24*row + 3*(7-col)
            ret[dstix:dstix+3] = a[srcix:srcix+3]

    return ret

parser = argparse.ArgumentParser()
parser.add_argument('rawfile')
parser.add_argument('ipaddr')
parser.add_argument('-p', '--port', default=5000, metavar='udp_port')

args = parser.parse_args()

fin = open(args.rawfile, 'rb')
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

while True :
    buf = fin.read(64*3)
    print('Read ', len(buf), 'bytes.')
    sock.sendto(reshuffle(buf), (args.ipaddr, args.port))
    time.sleep(0.05)
