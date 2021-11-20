INCLUDE "graphics.inc"

SECTION "Night Panorama", ROMX
    xNightPanorama::
        ; DMG
        DW xGfxNightPanoramaTiles
        DW xNightPanoramaMap
        ; CGB
        DW xGfxNightPanoramaTiles
        DW xNightPanoramaMap
        DW xNightPanoramaAttributes
        DW xNightPanoramaPalettes
    xGfxNightPanoramaTiles::
        INCBIN "res/panorama/night/night_tiles.2bpp"
    xNightPanoramaMap::
        INCBIN "res/panorama/night/night_map.tilemap"
    xNightPanoramaAttributes::
        INCBIN "res/panorama/night/night_map.attrmap"
    xNightPanoramaPalettes::
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
