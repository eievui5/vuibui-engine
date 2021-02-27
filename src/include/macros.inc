
    IF !DEF(MACROS_INC)
MACROS_INC SET 1

; Adds a into \1 \2. a will become \2's result.
; @ add_r16_a r8, r8
; @ 5 bytes
; @ 5 cycles
MACRO add_r16_a
    add a, \2 ; a = low + old_l
    ld \2, a  ; a = low + old_l = new_l
    adc a, \1 ; a = new_l + old_h + carry
    sub a, \2    ; a = old_h + carry
    ld \1, a
ENDM

; Far pointer. Bank, then pointer.
MACRO far_pointer
    db BANK(\1)
    dw \1
ENDM

; Seek through \1 \2 (r16) from \3 to \4. Slow but 16-bit safe. Avoid using this.
; @ StructSeek r8, r8, Current pointer, Target pointer.
; @ 7 bytes
; @ 7 cycles
MACRO StructSeek
    ld a, \4 - \3
    add_r16_a \1, \2
ENDM

; Seek through \1 (r8) from \2 to \3. Only 8-bit; prone to overflowing. Will warn about being used stupidly.
; @ StructSeekUnsafe r8, Current pointer, Target pointer.
; @ 4 bytes
; @ 4 cycles
MACRO StructSeekUnsafe
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
MACRO SeekAssert
    IF \2 - \1 != \3
        WARN "Invalid Seeking"
    ENDC
ENDM

    ENDC
