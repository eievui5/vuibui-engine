    IF !DEF(STAT_INC)
DEF STAT_INC SET 1

INCLUDE "include/enum.inc"

    start_enum STATIC_FX
        enum NONE
        enum SHOW_HUD
        enum PRINT_SCROLL
        enum TEXTBOX_PALETTE
    end_enum

    start_enum RASTER_FX
        enum NONE
    end_enum

    ENDC