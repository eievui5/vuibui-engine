
INCLUDE "include/enum.inc"

DEF MAP_SIZE EQU 16 * 16

; Ends a mapdata definition
end_mapdata: MACRO 
    db MAPDATA_END
ENDM

; Spawns entity when entering a given room
; @ create_entity EntityPointer, PosY, PosX
create_entity: MACRO 
    IF _NARG != 3
        FAIL "Expected 3 args."
    ENDC
    db MAPDATA_ENTITY
    dw \1
    db \2, \3
ENDM
DEF sizeof_create_entity EQU 4

; Sets the Ally logic for the room. Optional, but should rarely go unused.
; @ ally_logic ALLY_MODE
MACRO ally_mode
    IF _NARG != 1
        FAIL "Expected 1 arg."
    ENDC
    db MAPDATA_ALLY_MODE
    db \1
ENDM

; Macro Data enumerations
    start_enum MAPDATA
        enum END
        enum ENTITY
        enum ALLY_MODE
    end_enum

; Map enumerations
    start_enum MAP
        enum OVERWORLD
    end_enum
