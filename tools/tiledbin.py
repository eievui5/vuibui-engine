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
import argparse
import json
import sys

def convert_map(infile, outfile, datafile):
    converted_tiles = False
    datafile.write("; Map data generated by tiledbin.py\n")
    for layer in json.loads(infile.read())['layers']:

        # Convert tiles to binary map
        if layer['type'] == 'tilelayer':
            # Have we already converted a map?
            if converted_tiles:
                print("WARN: Too many tile layers! Ignoring...")
                continue
            # Ensure that the map is of the proper size.
            if layer['height'] != 16 | layer['width'] != 16:
                print("ERROR: Input map must be 16 by 16 tiles.")
                sys.exit(1)
            # Write the map to the output file.
            tilemap = []
            # Tiled starts at 1, VuiBui starts at 0. Subtract 1.
            for byte in layer['data']:
                tilemap.append(byte - 1)
            outfile.write(bytearray(tilemap))
            converted_tiles = True

        # Convert objects to map metadata
        elif layer['type'] == 'objectgroup':
            for i in layer['objects']:
                datafile.write(f"    create_entity {i['name']}, {int(i['y'])}, {int(i['x'])}\n")

        # Warn on unknown layers.
        else:
            print(f"WARN: Unsupported or Unknown Layer type \"{layer['type']}\"! Ignoring...")
    return

def __main__():
    parser = argparse.ArgumentParser()
    parser.add_argument("-o", "--output", dest = "output", type = argparse.FileType('wb'), nargs = 1, required = True)
    parser.add_argument("-d", "--data", dest = "data", type = argparse.FileType('w'), nargs = 1, required = True)
    parser.add_argument("input", type = argparse.FileType('r'), nargs = 1)

    args = parser.parse_args()

    # Read i/o
    convert_map(args.input[0], args.output[0], args.data[0])

if __name__ == "__main__":
    __main__()
