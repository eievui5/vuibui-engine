
    IF !DEF(TILES_INC)
TILES_INC SET 1

INCLUDE "directions.inc"
INCLUDE "enum.inc"

; Tile Constants

    start_enum TILE
        enum CLEAR
        ; Entity Walls (Entities cannot pass these)
        enum COLLISION
        enum TRANSITION_DOWN
        enum TRANSITION_UP
        enum TRANSITION_RIGHT
        enum TRANSITION_LEFT
        ; End of entity walls.
    end_enum

; Used to set the carry flag when entities detect collision, because they should
; not pass through certain objects (Like transition tiles.)
MAX_ENTITY_WALL EQU TILE_TRANSITION_LEFT

; Ensure that TRANSITION enums match DIR enums
ASSERT TILE_TRANSITION_DOWN - TILE_TRANSITION_DOWN == DIR_DOWN
ASSERT TILE_TRANSITION_UP - TILE_TRANSITION_DOWN == DIR_UP
ASSERT TILE_TRANSITION_RIGHT - TILE_TRANSITION_DOWN == DIR_RIGHT
ASSERT TILE_TRANSITION_LEFT - TILE_TRANSITION_DOWN == DIR_LEFT

MAX_METATILES EQU 64

VRAM_TILES_OBJ EQU $8000
VRAM_TILES_SHARED EQU $8800
VRAM_TILES_BG EQU $9000

    ENDC
