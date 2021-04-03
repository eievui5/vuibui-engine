
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

DEF vPlainTiles EQU $97D0

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
        ; Player Poppy
        enum POPPY_DOWN_1
        enum POPPY_DOWN_2
        enum POPPY_UP_1
        enum POPPY_UP_2
        enum POPPY_RIGHT_1
        enum POPPY_RIGHT_2
        enum POPPY_RIGHT_STEP_1
        enum POPPY_RIGHT_STEP_2
        enum POPPY_DOWN_ACT
        enum POPPY_UP_ACT
        enum POPPY_RIGHT_ACT
        ; Player Tiber
        enum TIBER_DOWN_1
        enum TIBER_DOWN_2
        enum TIBER_UP_1
        enum TIBER_UP_2
        enum TIBER_RIGHT_1
        enum TIBER_RIGHT_2
        enum TIBER_RIGHT_STEP_1
        enum TIBER_RIGHT_STEP_2
        enum TIBER_DOWN_ACT
        enum TIBER_UP_ACT
        enum TIBER_RIGHT_ACT

        enum PLAYER_SPELL
        enum ARROW_DOWN
        enum ARROW_RIGHT_FLETCH
        enum ARROW_RIGHT_POINT
    end_enum

    ENDC