
INCLUDE "flags.inc"

SECTION "Bitfield Functions", ROM0

; Returns the mask of the input flag, and the address in `hl`
; This can be used to `and a, [hl]` or `or a, [hl] \ ld [hl], a`
; @ input:
; @ b:  Flag index
; @ output:
; @ a:  Flag mask
; @ hl: Flag address
GetBitfieldMask::
    ; Get the address containing the target bit.
    ld a, b
    and a, %11111000
    rra ; `and` always resets carry flag.
    rra
    rra
    ; add hl, a
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

    ; Get the proper bitmask Using the lower 3 bits.
    ld a, b
    and a, %00000111
    
; Returns the mask of the input value
; @ input:
; @ a:  Value
; @ output:
; @ a:  Mask
GetBitA::
    ; `a = 1 << a`. Used for indexing into bitfields.
    ; Thanks, calc84maniac.
    ; Check if resulting bit should be in high or low nibble
    sub a, 4
    jr nc, .highNibble
    ; Convert 0 -> $01, 1 -> $02, 2 -> $04, 3 -> $05
    add a, 2
    adc a, 3
    jr .fixupResult
.highNibble
    ; Convert 4 -> $10, 5 -> $20, 6 -> $40, 7 -> $50
    add a, -2
    adc a, 3
    swap a
.fixupResult
    ; If result was $05/$50, convert to $08/$80
    add a, a
    daa
    rra
    ret

SECTION "Flag Bitfield", WRAM0

wBitfield::
    ds (FLAG_MAX + 7)/8 ; Define enough bytes for every flag in "flags.inc"