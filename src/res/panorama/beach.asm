INCLUDE "graphics.inc"

SECTION "Beach Panorama", ROMX
    BeachPanorama::
        ; DMG
        DW GfxDMGBeachPanoramaTiles
        DW BeachPanoramaMap
        ; CGB
        DW GfxCGBBeachPanoramaTiles
        DW BeachPanoramaMap
        DW BeachPanoramaAttributes
        DW BeachPanoramaPalettes
    GfxDMGBeachPanoramaTiles:
        INCBIN "res/panorama/beach/dmg_beach_tiles.2bpp"
    GfxCGBBeachPanoramaTiles:
        INCBIN "res/panorama/beach/cgb_beach_tiles.2bpp"
    BeachPanoramaMap:
        INCBIN "res/panorama/beach/beach_map.tilemap"
    BeachPanoramaAttributes:
        INCBIN "res/panorama/beach/beach_map.attrmap"
    BeachPanoramaPalettes:
        pal 31, 31, 31, \
            16, 16, 31, \
             0,  0,  0, \
             0,  0, 31
        pal 20, 20,  6, \
            31, 31, 10, \
            10, 10,  5, \
             0,  0, 31
        pal  8, 18,  5, \
            16, 16, 31, \
             4,  9,  5, \
             0,  0,  0
        pal 12, 12,  0, \
            10, 10,  0, \
             4,  9,  5, \
             6,  6,  0
        pal  8, 18,  5, \
             8, 18,  5, \
             4,  9,  5, \
             2,  4,  3