"""
tiledworld.py
Convert Tiled .world files into complete VuiBui worlds.
This includes maps, metatiles, scripts, palettes, collision -- everything.

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
import os
import sys

class Room(object):
	name = ""
	path = ""
	json = ""
	x = 0
	y = 0
	has_script = False

def error(string):
	print(f"ERROR: {string}")
	sys.exit(1)

def warn(string):
	print(f"WARN: {string}")

def get_height_range(rooms):
	lowest = 0
	highest = 0

	for room in rooms:
		if room.y < lowest:
			lowest = room.y
		elif room.y > highest:
			highest = room.y

	return (lowest, highest)

def get_height(rooms):
	(lowest, highest) = get_height_range(rooms)
	return abs(lowest) + abs(highest) + 1

def get_width_range(rooms):
	lowest = 0
	highest = 0

	for room in rooms:
		if room.x < lowest:
			lowest = room.x
		elif room.x > highest:
			highest = room.x

	return (lowest, highest)

def get_width(rooms):
	(lowest, highest) = get_width_range(rooms)
	return abs(lowest) + abs(highest) + 1

def get_room(x, y, rooms):
	for room in rooms:
		if room.x == x and room.y == y:
			return room
	return None

def get_path(path, exclude_src = False):
	return path[4 if path.startswith("src") and exclude_src else 0:path.find(os.path.basename(path))]

def name_from_path(path):
	return os.path.basename(path).split('.', 1)[0].capitalize()

def __main__():
	parser = argparse.ArgumentParser()
	parser.add_argument("-o", "--output", dest = "output", type = argparse.FileType('w'), nargs = 1, required = True)
	parser.add_argument("-i", "--include", dest = "include", type = argparse.FileType('w'), nargs = 1, required = True)
	parser.add_argument("input", type = argparse.FileType('r'), nargs = 1, help = "Input .world file.")

	args = parser.parse_args()
	infile = args.input[0]
	outfile = args.output[0]
	include_file = args.include[0]
	map_name = name_from_path(infile.name)
	rooms = []

	# Create rooms structures.
	for room in json.loads(infile.read())["maps"]:
		new_room = Room()
		new_room.path = room["fileName"]
		new_room.name = name_from_path(new_room.path)
		new_room.json = json.loads(open(get_path(infile.name) + new_room.path, "r").read())
		new_room.x = room["x"] // 256
		new_room.y = room["y"] // 256
		if room["x"] % 256 != 0 or room["y"] % 256 != 0:
			error(f"Room position of {new_room.path} must be a multiple of 256.")
		if (room["width"] != 256 or room["height"] != 256):
			error(f"Width and height of {new_room.path} must be 256.")
		rooms.append(new_room)

	if get_height(rooms) > 16 and get_width(rooms) > 16:
		error("A world must be 16x16 rooms or smaller.")

	outfile.write("; Generated by tiledworld.py for use in the VuiBui engine.\n\n")
	outfile.write(f"SECTION \"{map_name} World Map\", ROMX\n")
	if include_file:
		include_file.write("; Generated by tiledworld.py for use in the VuiBui engine.\n\n")

	# INCBIN each of the rooms. This should eventually happen directly in
	# tiledworld rather than splitting the work with tiledbin.
	outfile.write("; --- Maps ---\n")
	for room in rooms:
		outfile.write(f"{room.name}:\n")
		outfile.write(f"    INCBIN \"{get_path(infile.name, True) + room.path.split('.', 1)[0] + '.tilemap'}\"\n")

	outfile.write("\n; --- Scripts ---\n")
	for room in rooms:
		try:
			script_path = get_path(infile.name) + room.path.split('.', 1)[0] + '.roomscript'
			open(script_path)
			room.has_script = True
			outfile.write(f"{name_from_path(room.name)}_script:\n")
			outfile.write(f"    INCLUDE \"{script_path}\"\n")
			outfile.write(f"    end_mapdata\n")
		except:
			pass

	# Get the tileset path and assert that there is only one.
	tileset_path = ""

	for room in rooms:
		if len(room.json["tilesets"]) < 1:
			error(f"{room.path} has no tileset!")
		if len(room.json["tilesets"]) > 1:
			warn(f"{room.path} has more than 1 tileset. Only the first will be used.")
		if not tileset_path:
			tileset_path = room.json["tilesets"][0]["source"]
		if tileset_path != room.json["tilesets"][0]["source"]:
			error(f"Multiple tilesets detected in {map_name}! All cells in a world must share a tileset.")

	tileset = get_path(infile.name) + json.loads(open(get_path(infile.name) + tileset_path, 'r').read())['image']

	# Include the tileset.
	outfile.write(
f"""
; --- Tileset ---
{name_from_path(tileset_path)}_tileset:
    INCBIN \"{tileset[4 if tileset.startswith("src") else 0:].split('.', 1)[0] + '.2bpp'}\"
""")

	# Include the palettes.
	outfile.write(
f"""
; --- Palettes ---
{name_from_path(tileset_path)}_palettes:
	pal_blank
""")

	# Incude the metatile data.
	outfile.write(
f"""
; --- Metatiles ---
{name_from_path(tileset_path)}:
.definitions
    INCLUDE \"{tileset[4 if tileset.startswith("src") else 0:].split('.', 1)[0] + '.mtiledata'}\"
.end
.attributes
    DS 12 * 4, 0 ; TODO
""")
	# Collision data here
	outfile.write(".data\n")
	try:
		for line in open(tileset.split('.', 1)[0] + ".tdata").read().splitlines():
			line = line.strip()
			if line == "" or line[0] == ";":
				continue
			outfile.write(f"    DB TILEDATA_{line.upper()}\n")
	except:
		error(f"Failed to open {tileset.split('.', 1)[0] + '.tdata'}. Is it missing?")

	# Prepare world structure.
	outfile.write(
f"""
x{map_name}::
	define_map \\
        {get_width(rooms)}, {get_height(rooms)}, \\ ; Width, Size
	    {name_from_path(tileset_path)}_tileset, \\ ; Tileset
	    {name_from_path(tileset_path)}_palettes, \\ ; Palettes - TODO
	    {name_from_path(tileset_path)} ; Metatile data
.map""")

	# Output room matrix.
	(lowest_height, highest_height) = get_height_range(rooms)
	(lowest_width, highest_width) = get_width_range(rooms)

	for y in range(lowest_height, highest_height + 1):
		outfile.write("\n    DW ")
		for x in range(lowest_width, highest_width + 1):
			room = get_room(x, y, rooms)

			if room is None:
				outfile.write("null, ")
			else:
				outfile.write(f"{room.name}, ")
				if include_file:
					include_file.write(f"DEF {room.name}_X EQU {x + abs(lowest_width)}\n")
					include_file.write(f"DEF {room.name}_Y EQU {y + abs(lowest_height)}\n")

	# And finally, output room script matrix.
	outfile.write("\n.data")
	for y in range(lowest_height, highest_height + 1):
		outfile.write("\n    DW ")
		for x in range(lowest_width, highest_width + 1):
			room = get_room(x, y, rooms)

			if room is None or not room.has_script:
				outfile.write("null, ")
			else:
				outfile.write(f"{name_from_path(room.name)}_script, ")

if __name__ == "__main__":
	__main__()
