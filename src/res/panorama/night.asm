INCLUDE "graphics.inc"

SECTION "Night Panorama", ROMX
    NightPanorama::
        ; DMG
        DB 45 ; no of tiles
        DW pb16_NightPanoramaTiles
        DW NightPanoramaMap
        ; CGB
        DB 45 ; no of tiles
        DW pb16_NightPanoramaTiles
        DW NightPanoramaMap
        DW NightPanoramaAttributes
        DW NightPanoramaPalettes
    pb16_NightPanoramaTiles::
        INCBIN "res/panorama/night/night_tiles.pb16"
    NightPanoramaMap::
        INCBIN "res/panorama/night/night_map.tilemap"
    NightPanoramaAttributes::
        INCBIN "res/panorama/night/night_map.attrmap"
    NightPanoramaPalettes::
        pal 31, 31, 31, \
            10, 00, 10, \
            00, 10, 10, \
            01, 01, 02
        pal 31, 31, 16, \
            18, 18, 09, \
            10, 10, 05, \
            01, 01, 02
        pal 31, 31, 31, \
            18, 18, 18, \
            04, 10, 05, \
            00, 00, 03
        pal 00, 00, 00, \
            12, 12, 22, \
            03, 03, 07, \
            00, 00, 03