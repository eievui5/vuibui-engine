add_hl_a: Macro ; deprecated
    add_r16_a h, l
ENDM

; Adds a into \1 \2. a will become \2's result.
; @ 5 bytes
; @ 5 cycles
add_r16_a: Macro
    add a, \2 ; a = low + old_l
    ld \2, a  ; a = low + old_l = new_l
    adc a, \1 ; a = new_l + old_h + carry
    sub \2    ; a = old_h + carry
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

; Seek through \1 \2 from \3 to \4. Slow but 16-bit safe.
; @ 7 bytes
; @ 7 cycles
StructSeek: Macro
    ld a, \4 - \3
    add_r16_a
ENDM

; Seek through \1 from \2 to \3. Only 8-bit; prone to overflowing.
; @ 4 bytes
; @ 4 cycles
StructSeekUnsafe: Macro
    ld a, \3 - \2 ; Distance between fields
    add a, \1
    ld \1, a
ENDM