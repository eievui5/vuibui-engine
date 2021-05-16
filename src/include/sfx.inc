
    IF !DEF(SFX_INC)
DEF SFX_INC EQU 1

INCLUDE "include/enum.inc"

    start_enum SOUND
        enum FLAME
        enum ICE_SPELL
        enum LIGHTNING
    end_enum

    ENDC