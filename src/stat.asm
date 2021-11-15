INCLUDE "banks.inc"
INCLUDE "engine.inc"
INCLUDE "graphics.inc"
INCLUDE "hardware.inc"
INCLUDE "stdopt.inc"

SECTION "Stat Interrupt", ROM0[$48]
    ; Save register state
    push af
    push bc
    push hl
    jp Stat

SECTION "STAT Handler", ROM0

Stat:
    ldh a, [hCurrentBank]
    ld [wInterruptBankBuffer], a

    ld a, [wStaticFX]
    ASSERT STATIC_FX_NONE == 0
    and a, a
    jp z, ExitStat
    ASSERT STATIC_FX_SHOW_HUD == 1
    dec a
    jr z, ShowHUD
    ASSERT STATIC_FX_PRINT_SCROLL == 2
    dec a
    jr z, PrintScroll
    ASSERT STATIC_FX_TEXTBOX_PALETTE == 3
    dec a
    jr z, TextboxPalette

    rst CrashHandler

ShowHUD:
    ; Wait for safe VRAM access
:   ld a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, SCREEN_HUD
    ldh [rLCDC], a
    ld a, 256 - (3*8) - 144
    ldh [rSCY], a
    xor a, a
    ldh [rSCX], a
    jp ExitStat

PrintScroll:
    ; Calculate Scroll (scroll by 2 every other frame)
    ld a, [wHUDPrintScroll]
    bit 0, a
    jr z, :+
    dec a
:   ld b, a

    ; Wait for safe VRAM access
:   ld a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, SCREEN_HUD
    ldh [rLCDC], a
    ld a, 256 - (3*8) - 144
    ldh [rSCY], a
    ld a, b
    ldh [rSCX], a

    ; Schedule another interrupt to undo this effect once needed
    ld a, STATIC_FX_SHOW_HUD
    ld [wStaticFX], a
    ld a, 144 - 16 - 1
    ldh [rLYC], a

    jr ExitStat

TextboxPalette:

    ; Precompute palette

    ld a, $80 | (7 * 8) + 6
    ldh [rBCPS], a

    ld hl, wTextboxPalsBank
    ASSERT wTextboxPalsBank + 1 == wTextboxPalettes
    ld a, [hli]
    rst SwapBank

    ld a, [hli]
    ld l, [hl]
    ld h, a
    ld a, [wTextboxFadeProgress]
    ASSERT sizeof_COLOR == 3
    ld d, a
    add a, a ; a * 2
    add a, d ; a * 3
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; Convert palette and store in `de`
    call Convert24BitPalette

    ld a, [wTextboxFadeProgress]
    inc a
    ld [wTextboxFadeProgress], a
    cp a, 20
    jr nz, :+

    xor a, a
    ld [wTextboxFadeProgress], a
    ld a, 144 - 40
    jr :++

:   ldh a, [rLYC]
    add a, 2
:   ldh [rLYC], a

    ; Wait for safe VRAM access
:   ld a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, e
    ldh [rBCPD], a
    ld a, d
    ldh [rBCPD], a
    ld a, SCREEN_HUD
    ldh [rLCDC], a
    ld a, 256 - (3*8) - 144
    ldh [rSCY], a
    xor a, a
    ldh [rSCX], a
    fall ExitStat

ExitStat:
    ; Restore register state
    ld a, [wInterruptBankBuffer]
    rst SwapBank
    pop hl
    pop bc
    pop af
    reti

SECTION "Stat Data", WRAM0

; Single FX byte for regular STAT processing
wStaticFX::
    DS 1

; A pointer to the current text's precomputed palette design
wTextboxPalsBank::
    DS 1
wTextboxPalettes::
    DS 2
; How far along the palette design are we?
wTextboxFadeProgress::
    DS 1
