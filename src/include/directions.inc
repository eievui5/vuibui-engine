
INCLUDE "include/enum.inc"

    IF !DEF(DIRECTIONS_INC)
DIRECTIONS_INC SET 1

; Starting from 0 for offsets
    start_enum DIR
        enum DOWN
        enum UP
        enum RIGHT
        enum LEFT
    end_enum

    ENDC
