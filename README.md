
Currently being built on RGBDS 0.5.1

Requires a POSIX environment with GNU make and Python to build.

Rangi's Tilemap Studio is used to create binary map files for the menus.
A custom mapping software is being slowly developed for creating world maps.

Naming Conventions:

- All labels are `PascalCase`
  - Prefix `v`: Video RAM
  - Prefix `s`: Save/External RAM
  - Prefix `w`: Work RAM
  - Prefix `h`: High RAM

- Compressed data is prefixed with the type of compression it uses.
  - Example: `pb16_GfxArrow`, `zip_Archive`, `lz_OtherCompression`

- Constants are in `ALL_CAPS`
- Macros are in `snake_case`