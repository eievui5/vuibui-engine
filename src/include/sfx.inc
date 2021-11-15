    IF !DEF(SFX_INC)
DEF SFX_INC EQU 1

INCLUDE "enum.inc"

    start_enum SOUND
        enum FLAME
        enum ICE_SPELL
        enum SHOCK_SPELL
        enum HEAL_SPELL
    end_enum

    ENDC
