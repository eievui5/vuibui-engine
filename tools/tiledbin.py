"""
tiledbin.py
A Tiled to binary map converter for use in the VuiBui engine.

Copyright (c) 2021 Eievui

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
"""
import json
import sys

def main():

    # Validate the command-line arguments
    if len(sys.argv) > 3:
        print("WARN: Too many command-line arguments. Excess will be ignored.")
    elif len(sys.argv) < 3:
        print("ERROR: Not enough command-line arguments.")
        print("Usage: python tiledbin.py <input> <output>")
        return

    # Read i/o
    converted_tiles = False
    for layer in json.loads(open(sys.argv[1], 'r').read())['layers']:

        # Convert tiles to binary map
        if layer['type'] == 'tilelayer':
            # Have we already converted a map?
            if converted_tiles: 
                print("WARN: Too many tile layers! Ignoring...")
                continue
            # Ensure that the map is of the proper size.
            if layer['height'] != 16 | layer['width'] != 16:
                print("ERROR: Input map must be 16 by 16 tiles.")
                return
            # Write the map to the output file.
            output = open(sys.argv[2], 'wb')
            tilemap = []
            # Tiled starts at 1, VuiBui starts at 0. Subtract 1.
            for byte in layer['data']:
                tilemap.append(byte - 1)
            output.write(bytearray(tilemap))
            print("Successfully wrote tile layer to \"%s\"!" % sys.argv[2])
            converted_tiles = True
        
        # Convert objects to map metadata
        elif layer['type'] == 'objectgroup':
            print("WARN: Object Layer is currently unsupported. Ignoring...")
        
        # Warn on unknown layers.
        else: 
            print(
            "WARN: Unsupported or Unknown Layer type \"%s\"! Ignoring..." % 
            layer['type'])
    return

main()