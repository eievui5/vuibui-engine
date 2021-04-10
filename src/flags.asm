
INCLUDE "include/flags.inc"

SECTION "Bitfield Functions", ROM0

; `a = 1 << a`. Used for indexing into bitfields.
; Courtesy of calc84maniac. Thanks.
; @ a:  Input bit, output mask.
GetAthBit::
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
    ds (FLAG_MAX-1)/8 + 1 ; Define enough bytes for every flag in "flags.inc"