#!/bin/bash

# Assemble the passed argument
# Then convert to Intel Hex
# And copy to clipboard

f=${1%%.*}
echo $f

$(z80asm -i $f.asm -o $f.bin)

$(srec_cat $f.bin -binary -offset 0x8000 -output $f.hex -intel -address-length=2)

$(cat $f.hex | clip.exe)
