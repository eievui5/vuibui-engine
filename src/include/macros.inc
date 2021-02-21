
    IF !DEF(MACROS_INC)
MACROS_INC SET 1

; Adds a into \1 \2. a will become \2's result.
; @ 5 bytes
; @ 5 cycles
add_r16_a: Macro
    add a, \2 ; a = low + old_l
    ld \2, a  ; a = low + old_l = new_l
    adc a, \1 ; a = new_l + old_h + carry
    sub a, \2    ; a = old_h + carry
    ld \1, a
ENDM


mult_hl_16: Macro 
    add hl, hl ; x2
    add hl, hl ; x4
    add hl, hl ; x8
    add hl, hl ; x16 !!
ENDM

; Multiply \1 by \2. Store the result in A. Does not work on A.
mult_r8_n8: MACRO 
    xor a
REPT \2
    add a, \1
ENDR
ENDM

; Seek through \1 \2 (r16) from \3 to \4. Slow but 16-bit safe.
; @ 7 bytes
; @ 7 cycles
StructSeek: Macro
    ld a, \4 - \3
    add_r16_a \1, \2
ENDM

; Seek through \1 (r8) from \2 to \3. Only 8-bit; prone to overflowing. If the distance between fields is 1 or -1, the macro will simply use inc/dec
; @ 4 bytes
; @ 4 cycles
StructSeekUnsafe: Macro
    IF \3 - \2 == 1
        inc \1
    ELIF \3 - \2 == -1
        dec \1
    ELSE
        ld a, \3 - \2 ; Distance between fields
        add a, \1
        ld \1, a
    ENDC
ENDM

    ENDC