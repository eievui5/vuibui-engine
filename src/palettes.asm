INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/graphics.inc"

SECTION "Update Palettes", ROM0

; Updates the system's palettes based on the shadow palettes. Takes a fade state
; as input to determine the target color.
; @ a:  Fading mode
UpdatePalettes::
    ld b, a ; Save fade mode.

    ; Branch if on CGB
    ldh a, [hSystem]
    and a, a
    jr nz, Cgb

    dec b
    jr z, .dmgFadeDark
    dec b
    jr z, .dmgFadeLight
    ; dec a
    jr .dmgReset

.dmgFadeDark
    ldh a, [rOBP0]
    scf
    rra
    scf
    rra
    ldh [rOBP0], a
    ld b, a
    ldh a, [rOBP1]
    scf
    rra
    scf
    rra
    ldh [rOBP1], a
    and a, b
    ld b, a
    ldh a, [rBGP]
    scf
    rra
    scf
    rra
    ldh [rBGP], a
    and a, b
    cp a, $FF
    ret nz
    xor a, a
    ld [wPaletteState], a
    ret
.dmgFadeLight
    ld a, [wFrameTimer]
    and a, %11 ; every 4th frame
    ret nz

    ldh a, [rOBP0]
    add a, a ; a << 1
    add a, a ; a << 2
    ldh [rOBP0], a
    ld b, a
    ldh a, [rOBP1]
    add a, a ; a << 1
    add a, a ; a << 2
    ldh [rOBP1], a
    or a, b
    ld b, a
    ldh a, [rBGP]
    add a, a ; a << 1
    add a, a ; a << 2
    ldh [rBGP], a
    or a, b
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
    cp a, PALETTE_STATE_RESET
    jr z, CgbReset
    jr CgbFade

CgbReset:
    ld hl, wBCPD
    ld c, 8 * 4 ; Number of colors
    ; Reset BCPS
    ld a, BCPSF_AUTOINC
    ldh [rBCPS], a
.backgroundLoop
    push hl
    call Convert24BitPalette
    pop hl
    inc hl
    inc hl
    inc hl

    ; Wait for access and store
:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, e
    ldh [rBCPD], a
    ld a, d
    ldh [rBCPD], a

    dec c
    jr nz, .backgroundLoop

    ; `hl` has been offset to wOCPDTarget
    ld c, 8 * 4 ; Number of colors
    ; Reset OCPS
    ld a, OCPSF_AUTOINC
    ldh [rOCPS], a
.objectLoop
    push hl
    call Convert24BitPalette
    pop hl
    inc hl
    inc hl
    inc hl

    ; Wait for access and store
:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, e
    ldh [rOCPD], a
    ld a, d
    ldh [rOCPD], a

    dec c
    jr nz, .objectLoop
    xor a, a
    ld [wPaletteState], a
    ret

CgbFade:
    xor a, a
    ld [wFadedShadeCount], a
    ld hl, wBCPDTarget
    ld c, 8 * 4 ; Number of colors
    ; Reset BCPS
    ld a, BCPSF_AUTOINC
    ldh [rBCPS], a
.backgroundLoop
    push hl
    push bc
    call FadeToColor
    pop bc
    pop hl
    inc hl
    inc hl
    inc hl

    ; Wait for access and store
:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, e
    ldh [rBCPD], a
    ld a, d
    ldh [rBCPD], a

    dec c
    jr nz, .backgroundLoop

    ld hl, wOCPDTarget
    ld c, 8 * 4 ; Number of colors
    ; Reset OCPS
    ld a, OCPSF_AUTOINC
    ldh [rOCPS], a
.objectLoop
    push hl
    push bc
    call FadeToColor
    pop bc
    pop hl
    inc hl
    inc hl
    inc hl

    ; Wait for access and store
:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, e
    ldh [rOCPD], a
    ld a, d
    ldh [rOCPD], a

    dec c
    jr nz, .objectLoop
    ld a, [wFadedShadeCount]
    cp a, 192 ; Total number of R, G, and B values.
    ret nz
    xor a, a
    ld [wPaletteState], a ; disable the palette thread.
    ret

; Fades a given color towards the corresponding target value in `w*Target`,
; then converts the result to 15-bit and returns it in `de`.
; @ input:
; @ hl: Pointer to target color. ( Not the current color! )
; @ output:
; @ de:  Resulting 15-bit color.
FadeToColor:
    ld c, sizeof_COLOR
.loop
    ; Save target color to `b`
    ld a, [hli]
    ld b, a
    ld [wTargetColor], a
    push hl

    ; Offset to current color.
    ld de, (wBCPD - wBCPDTarget) - 1
    add hl, de
    
    ; Load target color and compare to current
    ld a, b
    cp a, [hl]
    ld a, [wFadeSpeed] ; Loads leave flags untouched
    ld b, a
    ld a, [hl]
    jr z, .match ; Skip if they're already equal
    jr c, .down ; Go down if current > target
.up ; Go up if current < target
    add a, b
    ld b, a ; Store result
    ld a, [wTargetColor] ; Load target
    jr c, .overflow ; Arithmatic overflows should always overflow (black/white)
    ; Check for target overflow
    cp a, b
    jr nc, .store
    jr .overflow
    

.down
    sub a, b
    ld a, [wTargetColor] ; Load target
    jr c, .overflow ; Arithmatic overflows should always overflow (black/white)
    ld b, a ; Store result
    ; Check for overflow
    cp a, b
    jr c, .store
    jr .overflow

; Load the target color into the current color
.overflow
    ld [hl], a
; Signal that a shade matches.
.match
    ld a, [wFadedShadeCount]
    inc a
    ld [wFadedShadeCount], a
    jr .decrement

.store
    ld [hl], b
.decrement
    dec c
    jr z, .convert
    pop hl
    jr .loop

; Just a little fall-through; offsets to the current palettes.
.convert
    pop bc ; clean stack
    dec hl
    dec hl
    ; Fall through to convert and return the converted colors.

; Converts a 24-bit palette to a 15-bit palette.
; @ input:
; @ hl:  Pointer to palette.
; @ output:
; @ de:  Resulting 15-bit palette.
Convert24BitPalette::
    ; The gameboy's palettes are BGR!
    ld d, 0 ; d needs to be clear so that `rl d` doesn't set carry

    ; First comes RED.
    ld a, [hli]
    ; First, mask out extra bits.
    and a, %11111000 ; Clears carry for rotate.
    ; Shift out the extra 3 bits of red in 24-bit color to convert to 15-bit.
    ; srl a
    ; srl a
    ; srl a
    swap a ; a >> 4
    rlca ; Rotate back to get a >> 3.
    ; Store shifted result in low byte.
    ld e, a

    ; Second is GREEN.
    ld a, [hli]
    ; First, mask out extra bits.
    and a, %11111000 ; Clears carry for rotate.
    ; Now rotate the upper two into the high byte.
    rla
    rl d
    rla
    rl d
    ; Combine into the low byte.
    or a, e
    ld e, a

    ; Last is BLUE.
    ld a, [hli]
    ; First, mask out extra bits.
    and a, %11111000 ; Clears carry for rotate.
    rra ; Only need to shift once.
    or a, d
    ld d, a
    ret

SECTION "Pal Common", WRAM0

; Used to begin a palette fade without blocking the main thread. Set to the
; desired fading mode.
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

; Used to store the current background palettes in 24-bit color format.
wBCPD::
    ds sizeof_PALETTE * 8
; Used to store the current object palettes in 24-bit color format.
wOCPD::
    ds sizeof_PALETTE * 8
; The target background palettes for a fade
wBCPDTarget::
    ds sizeof_PALETTE * 8
; The target object palettes for a fade
wOCPDTarget::
    ds sizeof_PALETTE * 8

; Used to control the speed of a palette fade. Should be a common factor of the
; difference between all current and target colors.
wFadeSpeed::
    ds 1

; Used to keep track of how many shades have fully faded.
; 16 Palettes = 64 Colors = 192 Shades.
wFadedShadeCount:
    ds 1

; Temporarily store the target color to check for overflows.
wTargetColor:
    ds 1