
Currently being built on RGBDS 0.5.1

Requires a POSIX environment with GNU make and Python to build.

[Rangi's Tilemap Studio](https://github.com/Rangi42/tilemap-studio) is used to create binary map files for the menus.

[Tiled](https://www.mapeditor.org/) is used to create the game's world map. Tilesets and Maps are stored as `.json` files to allow the use of other programs. The makefile will automatically use `tools/tiledbin.py` to convert Tiled's JSON files into binary maps.

Naming Conventions:

- All labels are `PascalCase`
  - Prefix `v`: Video RAM
  - Prefix `s`: Save/External RAM
  - Prefix `w`: Work RAM
  - Prefix `h`: High RAM
  - 
- Compressed data is prefixed with the type of compression it uses.
  - Example: `pb16_GfxArrow`, `zip_Archive`, `lz_OtherCompression`

- Constants are in `ALL_CAPS`
- Macros are in `snake_case`

- RGBDS directives are in all caps (Such as `SECTION`, `INCLUDE`, or `ASSERT`)
- Instructions and data are in lowercase (Such as `ld`, `call`, `db`, or `rw`)