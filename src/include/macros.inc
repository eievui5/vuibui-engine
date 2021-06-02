
    IF !DEF(MACROS_INC)
DEF MACROS_INC EQU 1

; Adds a into a 16-bit register.
; @ add_r16_a r16
; @ 5 bytes
; @ 5 cycles
MACRO add_r16_a
    IF _NARG == 1
        add a, LOW(\1) ; a = low + old_l
        ld LOW(\1), a  ; a = low + old_l = new_l
        adc a, HIGH(\1) ; a = new_l + old_h + carry
        sub a, LOW(\1)    ; a = old_h + carry
        ld HIGH(\1), a
    ELIF _NARG == 2
        add a, LOW(\2) ; a = low + old_l
        ld LOW(\1), a  ; a = low + old_l = new_l
        adc a, HIGH(\2) ; a = new_l + old_h + carry
        sub a, LOW(\1)    ; a = old_h + carry
        ld HIGH(\1), a
    ENDC
ENDM

MACRO lb
    assert -128 <= (\2) && (\2) <= 255, "Second argument to `lb` must be 8-bit!"
    assert -128 <= (\3) && (\3) <= 255, "Third argument to `lb` must be 8-bit!"
    ld \1, ((\2) << 8) | (\3)
ENDM

    ENDC