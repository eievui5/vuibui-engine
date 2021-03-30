    IF !DEF(BOOL_INC)
BOOL_INC SET 1

INCLUDE "structs.inc"

DEF FALSE EQU 0
DEF TRUE EQU 1
DEF sizeof_bool EQU 1

MACRO bool
    bytes 1, \1
ENDM

    ENDC
