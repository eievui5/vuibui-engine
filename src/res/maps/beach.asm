
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

BeachPalettes:
    pal_blank

BeachTiles:
    INCBIN "res/maps/beach/beach_metatiles.2bpp"

BeachMetatiles:
.definitions
    INCLUDE "res/maps/beach/beach_metatiles.mtiledata"
.end
.attributes
    DS 12*4, 0
.data
    DS 12, TILEDATA_CLEAR

Beach: INCBIN "res/maps/beach/beach_map.tilemap"