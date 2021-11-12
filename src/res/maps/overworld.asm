INCLUDE "enum.inc"
INCLUDE "flags.inc"
INCLUDE "graphics.inc"
INCLUDE "map.inc"
INCLUDE "tiledata.inc"

; TODO: Remove hard-coded bank test
SECTION "Overworld Map", ROMX

OverworldMap::
    define_map \
    2, 2, \ ; Size
    OverworldTiles, OverworldPalettes, DebugMetatiles ; Tileset
.map
    DW DebugMap, DebugMap2
    DW DebugMap2, DebugMap
.data
    DW DebugMap.data, DebugMap2.data
    DW DebugMap2.data, DebugMap.data

DebugMap: ; Using DebugMetatiles
    DB $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    DB $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    DB $01, $02, $01, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01
    DB $01, $00, $01, $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    DB $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    DB $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    DB $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    DB $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    DB $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    DB $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    DB $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    DB $04, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    DB $04, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    DB $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $05
    DB $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $05
    DB $01, $03, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
.data
    create_npc 0, PoppyMetasprites, 0, 1, 1, TiberGeneric
    create_entity LesserSlime, (256/2) + 32, (256/2) + 32
    spawn_item DebugCollectable, 128 - 32, 128, FLAG_DEBUG
    set_warp 0, 2, 2, MAP_BEACH, 1, 0, 256/2, 256/2
    end_mapdata

DebugMap2: ; Using DebugMetatiles
    DB $00, $06, $06, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    DB $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    DB $01, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    DB $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    DB $01, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    DB $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    DB $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    DB $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    DB $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    DB $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    DB $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    DB $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    DB $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    DB $04, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $05
    DB $04, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $05
    DB $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
.data:
    end_mapdata

CLEAR_TILE EQU $80
BLACK_TILE EQU $81
ROW_TILE EQU $82

SECTION "Overworld Tiles", ROMX
OverworldTiles:
    INCBIN "res/maps/overworld.h.2bpp"
.end::

SECTION "Overworld Palettes", ROMX
OverworldPalettes:
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
DebugMetatiles:
.definitions:
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
.end:

.attributes:
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

.data:
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