IF !DEF(VDEF_INC)
DEF VDEF_INC EQU 1

; Define a tile in VRAM. Must provide a name for the tile, and optionally its
; size in tiles. This produces 2 constants, an address pointing to the beginning
; of the tile, and an idof_ constant to get the tile's ID
MACRO dtile ; Name, [Size in tiles]
    ASSERT _NARG == 1 || _NARG == 2, "Expected 1 or 2 arguments!"
    ASSERT @ >= $8000 && @ < $9800, "Address {@} is outside of VRAM tile range!"
    IF @ >= $9000
        DEF idof_\1 EQU (@ - $9000) / 16
    ELSE
        DEF idof_\1 EQU (@ - $8000) / 16
    ENDC
    IF _NARG == 1
        v\1: ds 16
    ELSE
        v\1: ds (\2) * 16
    ENDC
ENDM

ENDC