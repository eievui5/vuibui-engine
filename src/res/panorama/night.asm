INCLUDE "include/graphics.inc"

SECTION "Night Panorama", ROMX
    NightPanorama::
        ; DMG
        db 45 ; no of tiles
        dw pb16_NightPanoramaTiles
        dw NightPanoramaMap
        ; CGB
        db 45 ; no of tiles
        dw pb16_NightPanoramaTiles
        dw NightPanoramaMap
        dw NightPanoramaAttributes
        dw NightPanoramaPalettes
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
            00, 00, 00
        pal 31, 31, 16, \
            18, 18, 09, \
            10, 10, 05, \
            00, 00, 00
        pal 31, 31, 31, \
            18, 18, 18, \
            04, 10, 05, \
            00, 00, 00
        pal 00, 00, 00, \
            16, 16, 22, \
            08, 08, 10, \
            00, 00, 00