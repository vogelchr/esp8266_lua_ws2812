#!/usr/bin/python
import PIL.Image
import argparse
import socket
import sys
import time

def img_into_led_bytearray(buf, img, width, height, offsx, offsy):
    for row in range(height) :
        for col in range(width) :
            # offset in LEDs!
            if (row % 2) == 0:  # first, third, fifth
                offs = width * row + col
            else:
                # backwards from next row
                offs = width * (row + 1) - (col + 1)


            # now offset is in bytes (3per/LED)
            offs *= 3
            if row+offsy < img.size[1] and col+offsx < img.size[0] :
                r, g, b = img.getpixel((col+offsx, row+offsy))
#                print(f'{row}, {col} -> {offs} {r},{g},{b}')
            else :
                r, g, b = 0, 0, 0
                print(f'{row}, {col} -> {offs} (not im image)')

            buf[offs] = r
            buf[offs+1] = g
            buf[offs+2] = b


parser = argparse.ArgumentParser()
parser.add_argument('image')
parser.add_argument('ipaddr')
parser.add_argument('-p', '--port', default=5000,
                    metavar='udp_port', help='UDP port number (def: 5000)')
parser.add_argument('-H', '--height', default=7, type=int,
                    help='LED matrix height (def: 7)')
parser.add_argument('-W', '--width', default=42, type=int,
                    help='LED matrix width (def: 42)')

args = parser.parse_args()

buf = bytearray(args.width * args.height * 3)
img = PIL.Image.open(args.image).convert('RGB')

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

for x in range(1 + img.size[0] - args.width) :
    img_into_led_bytearray(buf, img, args.width, args.height, x, 0)
    sock.sendto(buf, (args.ipaddr, args.port))
    time.sleep(0.03)
