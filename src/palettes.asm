
INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/switch.inc"

SECTION "Update Palettes", ROM0

UpdatePalettes::
    ld b, a
    ldh a, [hSystem]
    and a, a
    jr nz, .cgb

    ld a, [wPaletteTimer]
    inc a
    ld [wPaletteTimer], a
    bit 0, a
    ret z
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

.cgb
    ld a, b
    dec a
    switch
        case PALETTE_STATE_FADE_DARK - 1, .cgbFadeDark
        case PALETTE_STATE_FADE_LIGHT - 1, .cgbFadeLight
        case PALETTE_STATE_RESET - 1, .cgbReset
    end_switch
.cgbFadeDark
.cgbFadeLight
.cgbReset
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
wPaletteTimer:
    ds 1

SECTION UNION "Palettes", WRAM0
; CGB Pals

wBCPD::
    ds sizeof_PALETTE * 8
wOCPD::
    ds sizeof_PALETTE * 8

