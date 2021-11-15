    IF !DEF(BANKS_INC)
DEF BANKS_INC EQU 1

; Far pointer. Bank, then pointer.
MACRO far_pointer
    IF _NARG != 1
        FAIL "Expected 1 argument!"
    ENDC
    DB BANK(\1)
    DW \1
ENDM

    ENDC
