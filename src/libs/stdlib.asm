SECTION "Null", ROM0[$0000]
; null is equal to $0000. This should be used as a missing pointer value, and if
; called it will crash.
null::
    nop
    nop
    rst crash

SECTION "Call HL", ROM0[$0008]
; Used to call the address pointed to by `hl`. Mapped to `rst $08` or `rst CallHL`
CallHL::
    jp hl

SECTION "Call DE", ROM0
; Calls the value in `de` by pushing it and returning
CallDE::
    push de
    ret

SECTION "Jump Table", ROM0
; Jumps the the `a`th pointer. 128 pointers max. Place pointers after the call
; using `dw`. This function is faster than a decrement table if there are 8 or
; more destinations, and is always smaller.
; @ a:  Jump Offset.
; @ hl: Jump Table Pointer.
HandleJumpTable::
    ; a * 2 (pointers are 2 bytes!)
    add a, a
    ; add hl, a
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; Load pointer into hl
    ld a, [hli] ; low byte
    ld h, [hl] ; high byte
    ld l, a
    ; Now jump!
    jp hl