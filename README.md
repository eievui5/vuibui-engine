# VuiBui Engine

## Dependancies.

- [RGBDS 0.5.1 master branch](https://github.com/gbdev/rgbds)
- Python 3
- A C++ compiler
- GNU Make 4.3

The included tools are not entirely portable for the time being, but should work across all Linux machines (including WSL), and MacOS with some tweaking.
Windows *will not* be natively supported. Windows users must use WSL to compile.

## Tools

[Tiled](https://www.mapeditor.org/) is used to create the game's world map. Tilesets and Maps are stored as `.json` files to allow the use of other programs. The makefile will automatically convert Tiled's JSON files into binary maps.

## Naming Conventions

- All labels are `PascalCase`
  - Prefix `v`: Video RAM
  - Prefix `s`: Save/External RAM
  - Prefix `w`: Work RAM
  - Prefix `h`: High RAM

- Compressed data is prefixed with the type of compression it uses.
  - Example: `pb16_GfxArrow`, `zip_Archive`, `lz_OtherCompression`

- Constants are in `ALL_CAPS`
- Macros are in `snake_case`

- RGBDS directives are in all caps (Such as `SECTION`, `INCLUDE`, `ASSERT`, as well as `DB`, `DS`, `RW`, etc...)
- Instructions are in lowercase (Such as `ld`, `call`)
