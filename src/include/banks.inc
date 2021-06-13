    IF !DEF(BANKS_INC)
DEF BANKS_INC EQU 1

INCLUDE "include/enum.inc"

; Far pointer. Bank, then pointer.
MACRO far_pointer
    IF _NARG != 1
        FAIL "Expected 1 argument!"
    ENDC
    db BANK(\1)
    dw \1
ENDM

ENDC