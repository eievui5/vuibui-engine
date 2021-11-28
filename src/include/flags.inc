    IF !DEF(FLAGS_INC)
DEF FLAGS_INC EQU 1

INCLUDE "enum.inc"

    start_enum FLAG
        enum NULL

        enum DEBUG

        enum BEACH_HEART1

        enum MAX
    end_enum

DEF FLAG_SIZE EQU (FLAG_MAX + 7) / 8

ENDC
