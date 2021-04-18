
    IF !DEF(GRAPHICS_INC)
DEF GRAPHICS_INC SET 1

INCLUDE "enum.inc"
INCLUDE "hardware.inc"

; Max number of sprites
DEF MAXIMUM_SPRITES EQU 40 

; Metasprite end byte
DEF METASPRITE_END EQU $64

DEF VRAM_TILES_OBJ EQU $8000
DEF VRAM_TILES_SHARED EQU $8800
DEF VRAM_TILES_BG EQU $9000

DEF sizeof_PALETTE EQU 8

DEF DEFAULT_BLUE EQU OAMF_GBCPAL0
DEF DEFAULT_GREEN EQU OAMF_GBCPAL1
DEF DEFAULT_RED EQU OAMF_GBCPAL2
DEF DEFAULT_INV EQU OAMF_GBCPAL3

MACRO rgb
    IF _NARG != 3
        FAIL "Expected 3 args!"
    ENDC
    IF \1 > 31 || \2 > 31 || \3 > 31
        FAIL "Colors must be between 0 and 31"
    ENDC
    dw (\1) | (\2) << 5 | (\3) << 10
ENDM

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

DEF vPlainTiles EQU $97D0

    start_enum TILE, $80 - 9
        enum HEART, UI_START
        enum HEART_HALF
        enum HEART_EMPTY
        enum A_CHAR
        enum B_CHAR
        enum WHITE
        enum LIGHT
        enum DARK
        enum BLACK
    end_enum



    ENDC