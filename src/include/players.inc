
INCLUDE "include/enum.inc"

    IF !DEF(PLAYERS_INC)
PLAYERS_INC SET 1

ITEM_FIRE_WAND EQU 1

    start_enum PLAYER
        enum OCTAVIA
        enum POPPY
        enum TIBER
    end_enum

ENDC
