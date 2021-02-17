add_hl_a: Macro
    add a, l ; a = low + old_l
    ld l, a  ; a = low + old_l = new_l
    adc a, h ; a = new_l + old_h + carry
    sub l    ; a = old_h + carry
    ld h, a
ENDM

mult_hl_16: Macro 
    add hl, hl ; x2
    add hl, hl ; x4
    add hl, hl ; x8
    add hl, hl ; x16 !!
ENDM