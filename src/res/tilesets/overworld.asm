
INCLUDE "enum.inc"
INCLUDE "graphics.inc"
INCLUDE "tiledata.inc"

CLEAR_TILE EQU $80
BLACK_TILE EQU $81
ROW_TILE EQU $82

SECTION "Overworld Tiles", ROMX
pb16_OverworldTiles::
    INCBIN "res/tilesets/overworld.h.pb16"
.end::

SECTION "Overworld Palettes", ROMX
OverworldPalettes::
.bcpd
    pal_blank
    pal_blank
    pal_blank
    pal_blank
    pal_blank
    pal_blank
.ocpd
    pal_blank
    pal_blank
    pal_blank
    pal_blank
    pal_blank

SECTION "Metatiles", ROMX
DebugMetatiles::
.definitions::
    ; $00
    DB CLEAR_TILE, CLEAR_TILE
    DB CLEAR_TILE, CLEAR_TILE
    ; $01
    DB BLACK_TILE, BLACK_TILE
    DB BLACK_TILE, BLACK_TILE
    ; $02
    DB ROW_TILE, ROW_TILE
    DB ROW_TILE, ROW_TILE
    ; $03
    DB CLEAR_TILE, CLEAR_TILE
    DB CLEAR_TILE, CLEAR_TILE
    ; $04
    DB CLEAR_TILE, CLEAR_TILE
    DB CLEAR_TILE, CLEAR_TILE
    ; $05
    DB CLEAR_TILE, CLEAR_TILE
    DB CLEAR_TILE, CLEAR_TILE
    ; $06
    DB CLEAR_TILE, CLEAR_TILE
    DB CLEAR_TILE, CLEAR_TILE
.end::

.attributes::
    ; $00
    DB 0, 0
    DB 0, 0
    ; $01
    DB 0, 0
    DB 0, 0
    ; $02
    DB 1, 0
    DB 0, 1
    ; $03
    DB 0, 0
    DB 0, 0
    ; $04
    DB 0, 0
    DB 0, 0
    ; $05
    DB 0, 0
    DB 0, 0
    ; $06
    DB 0, 0
    DB 0, 0

.data::
    ; $00
    DB TILEDATA_CLEAR
    ; $01
    DB TILEDATA_COLLISION
    ; $02
    DB TILEDATA_CLEAR
    ; $03
    DB TILEDATA_TRANSITION_DOWN
    ; $04
    DB TILEDATA_TRANSITION_LEFT
    ; $05
    DB TILEDATA_TRANSITION_RIGHT
    ; $06
    DB TILEDATA_TRANSITION_UP