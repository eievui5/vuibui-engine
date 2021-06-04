
    IF !DEF(TILES_INC)
DEF TILES_INC EQU 1

INCLUDE "directions.inc"
INCLUDE "enum.inc"

; Tile Constants

    start_enum TILEDATA

        ; Collision will not detect these tiles
        enum CLEAR

        ; Only entities will collide with these tiles.
        enum ENTITY_COLLISION
        enum TRANSITION_DOWN, TRANSITIONS ; Tiles to determine screen transitions.
        enum TRANSITION_UP
        enum TRANSITION_RIGHT
        enum TRANSITION_LEFT
        enum WARP_0, WARPS ; 4 Tiles corresponding to up to four warps in a map.
        enum WARP_1
        enum WARP_2
        enum WARP_3 ; End of entity walls
        
        ; Everything will collide with these tiles.
        enum COLLISION
        enum NPC_0
        enum NPC_1
        enum NPC_2
        enum NPC_3
    end_enum


; Ensure that TRANSITION enums match DIR enums
ASSERT TILEDATA_TRANSITION_DOWN - TILEDATA_TRANSITION_DOWN == DIR_DOWN
ASSERT TILEDATA_TRANSITION_UP - TILEDATA_TRANSITION_DOWN == DIR_UP
ASSERT TILEDATA_TRANSITION_RIGHT - TILEDATA_TRANSITION_DOWN == DIR_RIGHT
ASSERT TILEDATA_TRANSITION_LEFT - TILEDATA_TRANSITION_DOWN == DIR_LEFT

DEF MAX_METATILES EQU 64

    ENDC
