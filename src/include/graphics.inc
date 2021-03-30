
    IF !DEF(GRAPHICS_INC)
DEF GRAPHICS_INC SET 1

INCLUDE "enum.inc"

; Max number of sprites
DEF MAXIMUM_SPRITES EQU 40 

; Metasprite end byte
DEF METASPRITE_END EQU $64

DEF VRAM_TILES_OBJ EQU $8000
DEF VRAM_TILES_SHARED EQU $8800
DEF VRAM_TILES_BG EQU $9000

; Tile constants

    start_enum TILE, 0, 2
        ; Player Octavia
        enum OCTAVIA_DOWN_1
        enum OCTAVIA_DOWN_2
        enum OCTAVIA_UP_1
        enum OCTAVIA_UP_2
        enum OCTAVIA_RIGHT_1
        enum OCTAVIA_RIGHT_2
        enum OCTAVIA_RIGHT_STEP_1
        enum OCTAVIA_RIGHT_STEP_2
        enum OCTAVIA_DOWN_ACT
        enum OCTAVIA_UP_ACT
        enum OCTAVIA_RIGHT_ACT

        enum PLAYER_SPELL
    end_enum

    ENDC