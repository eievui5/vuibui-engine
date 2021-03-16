
include "include/tiles.inc"

CLEAR_TILE EQU $00
BLACK_TILE EQU $01
ROW_TILE EQU $02

SECTION "Tiles", ROMX 
DebugTiles::
    ; CLEAR_TILE
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    ; BLACK_TILE
    db $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF
    ; $03
    db $FF, $00, $00, $FF
    db $FF, $00, $00, $FF
    db $FF, $00, $00, $FF
    db $FF, $00, $00, $FF
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

; Just a lookup table to save from storing 2 maps.
DebugMetatileData:: 
    ; $00
    db TILE_CLEAR
    ; $01
    db TILE_COLLISION
    ; $02
    db TILE_CLEAR
    ; $03
    db TILE_TRANSITION_DOWN
    ; $04
    db TILE_TRANSITION_LEFT
    ; $05
    db TILE_TRANSITION_RIGHT
    ; $06
    db TILE_TRANSITION_UP
.end::
