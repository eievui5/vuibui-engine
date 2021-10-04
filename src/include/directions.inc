
INCLUDE "enum.inc"

    IF !DEF(DIRECTIONS_INC)
DEF DIRECTIONS_INC EQU 1

    start_enum DIR
        enum DOWN
        enum UP
        enum RIGHT
        enum LEFT
    end_enum

; Starting from 1 for the transition handler, since 0 = no transition.
    start_enum TRANSDIR, 1
        enum DOWN
        enum UP
        enum RIGHT
        enum LEFT
        enum NONE
    end_enum

    ENDC
