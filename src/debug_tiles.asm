
INCLUDE "include/tiledata.inc"

CLEAR_TILE EQU $00
BLACK_TILE EQU $01
ROW_TILE EQU $02

SECTION "Tiles", ROMX 
DebugTiles::
    ; CLEAR_TILE
    ds 16, $00
    ; BLACK_TILE
    ds 16, $FF
    ; $03
    ds 16, $FF, $00, $00, $FF
.end::

SECTION "Metatiles", ROMX 
DebugMetatileDefinitions::
    ; $00
    db CLEAR_TILE, CLEAR_TILE
    db CLEAR_TILE, CLEAR_TILE
    ; $01
    db BLACK_TILE, BLACK_TILE
    db BLACK_TILE, BLACK_TILE
    ; $02
    db ROW_TILE, ROW_TILE
    db ROW_TILE, ROW_TILE
    ; $03
    db CLEAR_TILE, CLEAR_TILE
    db CLEAR_TILE, CLEAR_TILE
    ; $04
    db CLEAR_TILE, CLEAR_TILE
    db CLEAR_TILE, CLEAR_TILE
    ; $05
    db CLEAR_TILE, CLEAR_TILE
    db CLEAR_TILE, CLEAR_TILE
    ; $06
    db CLEAR_TILE, CLEAR_TILE
    db CLEAR_TILE, CLEAR_TILE
.end::

DebugMetatileAttributes::
    ; $00
    db 0, 0
    db 0, 0
    ; $01
    db 0, 0
    db 0, 0
    ; $02
    db 1, 0
    db 0, 1
    ; $03
    db 0, 0
    db 0, 0
    ; $04
    db 0, 0
    db 0, 0
    ; $05
    db 0, 0
    db 0, 0
    ; $06
    db 0, 0
    db 0, 0
.end::

; Just a lookup table to save from storing 2 maps.
DebugMetatileData:: 
    ; $00
    db TILEDATA_CLEAR
    ; $01
    db TILEDATA_COLLISION
    ; $02
    db TILEDATA_CLEAR
    ; $03
    db TILEDATA_TRANSITION_DOWN
    ; $04
    db TILEDATA_TRANSITION_LEFT
    ; $05
    db TILEDATA_TRANSITION_RIGHT
    ; $06
    db TILEDATA_TRANSITION_UP
.end::
