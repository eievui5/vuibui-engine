
    IF !DEF(TILES_INC)
DEF TILES_INC EQU 1

INCLUDE "directions.inc"
INCLUDE "enum.inc"

; Inequality checks require that these values not equal 1.
ASSERT TILEDATA_ENTITY_COLLISION - 1 != 0
ASSERT TILEDATA_COLLISION - 1 != 0

; Tile Constants

    start_enum TILEDATA

        ; Collision will not detect these tiles
        enum CLEAR
        ; ENTITY_COLLISION - 1 must not equal zero, so pad the enum for now
        enum BUFFER

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
        enum BURNABLE
    end_enum


; Ensure that TRANSITION enums match DIR enums
ASSERT TILEDATA_TRANSITION_DOWN - TILEDATA_TRANSITION_DOWN == DIR_DOWN
ASSERT TILEDATA_TRANSITION_UP - TILEDATA_TRANSITION_DOWN == DIR_UP
ASSERT TILEDATA_TRANSITION_RIGHT - TILEDATA_TRANSITION_DOWN == DIR_RIGHT
ASSERT TILEDATA_TRANSITION_LEFT - TILEDATA_TRANSITION_DOWN == DIR_LEFT

DEF MAX_METATILES EQU 64

    ENDC
