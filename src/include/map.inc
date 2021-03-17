
MAP_SIZE EQU 16 * 16

; Ends a mapdata definition
end_mapdata: MACRO 
    db MAPDATA_END
ENDM

; Spawns entity when entering a given room
; @ create_entity EntityPointer, PosY, PosX
create_entity: MACRO 
    IF _NARG != 3
        FAIL "Exepected 3 args."
    ENDC
    db MAPDATA_ENTITY
    dw \1
    db \2, \3
ENDM
sizeof_create_entity EQU 4

; Macro Data enumerations

MAPDATA_END EQU 0
MAPDATA_ENTITY EQU 1

; Map enumerations

WORLD_MAP EQU 0
