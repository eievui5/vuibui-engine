
INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/switch.inc"

SECTION "Update Palettes", ROM0

UpdatePalettes::
    ld b, a
    ldh a, [hSystem]
    and a, a
    jr nz, Cgb

    ld a, b
    dec a
    switch
        case PALETTE_STATE_FADE_DARK - 1, .dmgFadeDark
        case PALETTE_STATE_FADE_LIGHT - 1, .dmgFadeLight
        case PALETTE_STATE_RESET - 1, .dmgReset
    end_switch

.dmgFadeDark
    ldh a, [rOBP0]
    scf
    rra
    scf
    rra
    ldh [rOBP0], a
    ldh a, [rOBP1]
    scf
    rra
    scf
    rra
    ldh [rOBP1], a
    ldh a, [rBGP]
    scf
    rra
    scf
    rra
    ldh [rBGP], a
    cp a, $FF
    ret nz
    xor a, a
    ld [wPaletteState], a
    ret
.dmgFadeLight
    ld a, [wFrameTimer]
    bit 0, a
    ret nz
    bit 1, a
    ret nz

    ldh a, [rOBP0]
    rla
    res 0, a
    rla
    res 0, a
    ldh [rOBP0], a
    ldh a, [rOBP1]
    rla
    res 0, a
    rla
    res 0, a
    ldh [rOBP1], a
    ldh a, [rBGP]
    rla
    res 0, a
    rla
    res 0, a
    ldh [rBGP], a
    and a, a
    ret nz
    xor a, a
    ld [wPaletteState], a
    ret
.dmgReset
    ld a, [wBGP]
    ldh [rBGP], a
    ld a, [wOBP0]
    ldh [rOBP0], a
    ld a, [wOBP1]
    ldh [rOBP1], a
    xor a, a
    ld [wPaletteState], a
    ret

Cgb:
    ld a, b
    ASSERT PALETTE_STATE_FADE_DARK == 1
    dec a
    jr z, CgbFadeDark
    ASSERT PALETTE_STATE_FADE_LIGHT == 2
    dec a
    jr z, CgbFadeLight
    ASSERT PALETTE_STATE_RESET == 3
    dec a
    jr z, CgbReset
    ld b, b
    ret
CgbFadeDark:

CgbFadeLight:

    ld c, sizeof_PALETTE * 4 / 2
    ld a, [wFrameTimer]
    and a, 3
    jr z, .bg0
    dec a
    jr z, .bg1
    dec a
    jr z, .ob0
    dec a
    jr z, .ob1

.bg1
    ld hl, wBCPD + (sizeof_PALETTE * 4)
    ld a, %10000000 | (sizeof_PALETTE * 4)
    ldh [rBCPS], a
    jr .cgbBFadeLightLoop

.bg0
    ld hl, wBCPD
    ld a, %10000000 ; Auto-inc from index 0
    ldh [rBCPS], a
.cgbBFadeLightLoop
    call ColorFadeToWhite
    ld a, e
    ldh [rBCPD], a
    ld a, d
    ldh [rBCPD], a
    dec c
    jr nz, .cgbBFadeLightLoop
    
    jr .final

.ob1
    ld hl, wOCPD + (sizeof_PALETTE * 4)
    ld a, %10000000 | (sizeof_PALETTE * 4)
    ldh [rOCPS], a
    jr .cgbOFadeLightLoop

.ob0
    ld hl, wOCPD
    ld a, %10000000 ; Auto-inc from index 0
    ldh [rOCPS], a
.cgbOFadeLightLoop
    call ColorFadeToWhite
    ld a, e
    ldh [rOCPD], a
    ld a, d
    ldh [rOCPD], a
    dec c
    jr nz, .cgbOFadeLightLoop

.final
    ld a, [wFadeProgress]
    add a, %00001000 ; aligned increment
    jr nc, .skipExit
    ; Exit when wFadeProgress overflows.
    xor a, a
    ld [wPaletteState], a
.skipExit
    ld [wFadeProgress], a
    ret

CgbReset:
    ld hl, wBCPD
    ld a, %10000000 ; Auto-inc from index 0
    ldh [rBCPS], a
    ld c, sizeof_PALETTE * 8
.cgbBResLoop
    ld a, [hli]
    ldh [rBCPD], a
    dec c
    jr nz, .cgbBResLoop
    ASSERT wBCPD + sizeof_PALETTE * 8 == wOCPD
    ld a, %10000000 ; Auto-inc from index 0
    ldh [rOCPS], a
    ld c, sizeof_PALETTE * 8
.cgbOResLoop
    ld a, [hli]
    ldh [rOCPD], a
    dec c
    jr nz, .cgbOResLoop
    xor a, a
    ld [wPaletteState], a
    ret

; Fade the palettes at `hl`. Return result in `de`
ColorFadeToWhite:
    inc hl
; Blue
    ld a, [wFadeProgress]
    ld b, a
    ld a, [hl] ; Check first byte
    and a, %01111100 ; Mask in BLUE
    rla ; Align blue with highest bit
    add a, b ; add fade progress into blue
    jr c, .overflowBlue ; If it overflows, force blue to 31
    rra ; rotate `a` back into position
    rra ; We want blue aligned with the first byte to make green easier
    rra
    jr .finishBlue
.overflowBlue
    ld a, %00011111
.finishBlue
    ld d, a

; Green
    ; wFadeProgress is still loaded into `b`
    ld a, [hld] ; Load upper two bits of green
    and a, %00000011
    rra     ; 0000000x c
    rra     ; x0000000 c
    rra     ; xx000000
    ld e, a ; We can use `e` since it's not needed yet.
    ld a, [hl] ; Load the lower three bits of green (xxx00000)
    and a, %11100000
    rra     ; 0xxx0000
    rra     ; 00xxx000
    or a, e ; xxxxx000
    ; Green is now loaded into `a`
    add a, b ; add fade progress into green
    jr c, .overflowGreen
    jr .finishGreen
.overflowGreen
    ld a, %11111000
    ccf ; we know carry is set, so reset it
.finishGreen
    ld e, a

; Combine Blue and green
    rl e ; c xxxx0000
    rl d ; 00xxxxxc
    rl e ; c xxx00000
    rl d ; 0xxxxxcc
    ; de <- 0bbbbbgg ggg00000

; And finally, red
    ld a, [hli]
    inc hl
    and a, %00011111
    rla
    rla
    rla
    add a, b ; add fade progress into red
    jr c, .overflowRed
    rra 
    rra
    rra
    jr .finishRed
.overflowRed
    ld a, %00011111
.finishRed
    or a, e
    ld e, a
    ret




SECTION "Pal Common", WRAM0

wPaletteState::
    ds 1

SECTION UNION "Palettes", WRAM0
; DMG Pals
wBGP::
    ds 1
wOBP0::
    ds 1
wOBP1::
    ds 1

SECTION UNION "Palettes", WRAM0
; CGB Pals

wBCPD::
    ds sizeof_PALETTE * 8
wOCPD::
    ds sizeof_PALETTE * 8
wFadeProgress:
    ds 1

