
    IF !DEF(MACROS_INC)
DEF MACROS_INC SET 1

; Adds a into a 16-bite register.
; @ add_r16_a r16
; @ 5 bytes
; @ 5 cycles
add_r16_a: MACRO
    IF _NARG == 1
        add a, LOW(\1) ; a = low + old_l
        ld LOW(\1), a  ; a = low + old_l = new_l
        adc a, HIGH(\1) ; a = new_l + old_h + carry
        sub a, LOW(\1)    ; a = old_h + carry
        ld HIGH(\1), a
    ELSE
        add a, \2 ; a = low + old_l
        ld \2, a  ; a = low + old_l = new_l
        adc a, \1 ; a = new_l + old_h + carry
        sub a, \2    ; a = old_h + carry
        ld \1, a
    ENDC
ENDM

MACRO abs_a
    bit 7, a
    jr z, :+
    cpl
    inc a
  :
ENDM

; Seek through \1 (r8) from \2 to \3. Only 8-bit; prone to overflowing. Will warn about being used stupidly.
; @ StructSeekUnsafe r8, Current pointer, Target pointer.
; @ 4 bytes
; @ 4 cycles
StructSeekUnsafe: MACRO 
    IF \3 - \2 == 1
        inc \1
        WARN "1 Distance. This should be optimized by hand"
    ELIF \3 - \2 == -1
        dec \1
        WARN "-1 Distance. This should be optimized by hand"
    ELIF \3 - \2 == 2
        inc \1
        inc \1
        WARN "2 Distance. This should be optimized by hand"
    ELIF \3 - \2 == -2
        dec \1
        dec \1
        WARN "-2 Distance. This should be optimized by hand"
    ELSE
        ld a, \3 - \2 ; Distance between fields
        add a, \1
        ld \1, a
    ENDC
ENDM

; Used to confirm that a hand-optimized seek is valid.
SeekAssert: MACRO 
    IF \2 - \1 != \3
        WARN "Invalid Seeking"
    ENDC
ENDM

    ENDC
