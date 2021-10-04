
INCLUDE "map.inc"
INCLUDE "graphics.inc"
INCLUDE "tiledata.inc"
INCLUDE "save.inc"

SECTION "Beach Map", ROMX

BeachMap::
    define_map \
    1, 1, \ ; Size
    18, pb16_BeachTiles, \ ; Tileset
    BeachPalettes, \
    BeachMetatiles
.map
    dw Beach
.data
    dw .mapData

.mapData
    set_respawn \
        1, 0, 0, \
        128, 128, \
        144, 128, \
        112, 128
    end_mapdata

pb16_BeachTiles: INCBIN "res/maps/beach/beach_tiles.pb16"
BeachPalettes:
    pal_blank
BeachMetatiles:
.definitions
    db $80, $80
    db $80, $80

    db $8A, $8B
    db $90, $91

    db $82, $83
    db $83, $82

    db $7C, $81
    db $7C, $7C

    db $90, $91
    db $90, $91

    db $82, $84
    db $84, $80

    db $7C, $7C
    db $86, $87

    db $7C, $7C
    db $88, $87

    db $7C, $85
    db $88, $89

    db $8C, $8D
    db $8C, $8D

    db $8E, $8D
    db $8E, $8D

    db $8E, $8F
    db $8E, $8F
.end
.attributes
    ds 12*4, 0
.data
    ds 12, TILEDATA_CLEAR

Beach: INCBIN "res/maps/beach/beach_map.tilemap"
