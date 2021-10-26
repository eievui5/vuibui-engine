
INCLUDE "map.inc"
INCLUDE "graphics.inc"
INCLUDE "tiledata.inc"
INCLUDE "save.inc"

SECTION "Beach Map", ROMX

BeachMap::
    define_map \
    1, 1, \ ; Size
    BeachTiles, \ ; Tileset
    BeachPalettes, \
    BeachMetatiles
.map
    DW Beach
.data
    DW .mapData

.mapData
    set_respawn \
        1, 0, 0, \
        128, 128, \
        144, 128, \
        112, 128
    end_mapdata

BeachTiles: INCBIN "res/maps/beach/beach_tiles.2bpp"

BeachPalettes:
    pal_blank

BeachMetatiles:
.definitions
    DB $80, $80
    DB $80, $80

    DB $8A, $8B
    DB $90, $91

    DB $82, $83
    DB $83, $82

    DB $7C, $81
    DB $7C, $7C

    DB $90, $91
    DB $90, $91

    DB $82, $84
    DB $84, $80

    DB $7C, $7C
    DB $86, $87

    DB $7C, $7C
    DB $88, $87

    DB $7C, $85
    DB $88, $89

    DB $8C, $8D
    DB $8C, $8D

    DB $8E, $8D
    DB $8E, $8D

    DB $8E, $8F
    DB $8E, $8F
.end
.attributes
    DS 12*4, 0
.data
    DS 12, TILEDATA_CLEAR

Beach: INCBIN "res/maps/beach/beach_map.tilemap"