
INCLUDE "include/enum.inc"

    IF !DEF(DAMAGE_INC)
DAMAGE_INC SET 1

    start_enum DAMAGE_EFFECT, 16, 16 ; Start on the upper nibble
        enum FIRE
        enum ICE
        enum SHOCK
    end_enum

    ENDC
