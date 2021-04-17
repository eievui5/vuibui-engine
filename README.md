
Currently being built on RGBDS 0.5.0-rc2

A local copy of RGBDS is included for Windows.
The makefile will automatically use the included version.

Naming Conventions:

- All labels are `PascalCase`
  - Prefix `m`: MBC5 registers
  - Prefix `v`: Video RAM
  - Prefix `s`: Save/External RAM
  - Prefix `w`: Work RAM
  - Prefix `h`: High RAM

- Compressed data is prefixed with the type of compression it uses.
  - Example: `pb16_GfxArrow`, `zip_Archive`, `lz_OtherCompression`

- Constants are in `ALL_CAPS`
- Macros are in `snake_case`