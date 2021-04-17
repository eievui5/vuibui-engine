
    IF !DEF(TILES_INC)
DEF TILES_INC SET 1

INCLUDE "directions.inc"
INCLUDE "enum.inc"

; Tile Constants

    start_enum TILE
        enum CLEAR
        ; Entity Walls (Entities cannot pass these)
        enum COLLISION 
        enum TRANSITION_DOWN, TRANSITIONS ; Tiles to determine screen transitions.
        enum TRANSITION_UP
        enum TRANSITION_RIGHT
        enum TRANSITION_LEFT
        enum WARP_0, WARPS ; 4 Tiles corresponding to up to four warps in a map.
        enum WARP_1
        enum WARP_2
        enum WARP_3, ENTITY_WALL_MAX ; End of entity walls
        ; End of entity walls.
    end_enum

DEF vPlainTiles EQU $97D0

    start_enum TILE, $80 - 9
        enum HEART
        enum HEART_HALF
        enum HEART_EMPTY
        enum A_CHAR
        enum B_CHAR
        enum WHITE
        enum LIGHT
        enum DARK
        enum BLACK
    end_enum

; Ensure that TRANSITION enums match DIR enums
ASSERT TILE_TRANSITION_DOWN - TILE_TRANSITION_DOWN == DIR_DOWN
ASSERT TILE_TRANSITION_UP - TILE_TRANSITION_DOWN == DIR_UP
ASSERT TILE_TRANSITION_RIGHT - TILE_TRANSITION_DOWN == DIR_RIGHT
ASSERT TILE_TRANSITION_LEFT - TILE_TRANSITION_DOWN == DIR_LEFT

DEF MAX_METATILES EQU 64

    ENDC
