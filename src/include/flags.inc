    IF !DEF(FLAGS_INC)
DEF FLAGS_INC EQU 1

INCLUDE "enum.inc"

    start_enum FLAG
        enum NULL

        enum DEBUG

        enum MAX
    end_enum

ENDC
