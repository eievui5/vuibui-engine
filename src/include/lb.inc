
    IF !DEF(MACROS_INC)
DEF MACROS_INC EQU 1

MACRO lb
    assert -128 <= (\2) && (\2) <= 255, "Second argument to `lb` must be 8-bit!"
    assert -128 <= (\3) && (\3) <= 255, "Third argument to `lb` must be 8-bit!"
    ld \1, ((\2) << 8) | (\3)
ENDM

    ENDC