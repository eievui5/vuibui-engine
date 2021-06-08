INCLUDE "include/banks.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/stat.inc"

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

    ld a, [wStatFXMode]
    and a, a
    jr nz, FXMode

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

    ld b, b
    jp ExitStat


FXMode:
    ; Offset rLYC ( uses odd numbers! )
    ldh a, [rLYC]
    ld b, a
    add a, 2
    cp a, 143
    jr c, :+
    ld a, 1
:   ldh [rLYC], a
    ld a, b

    ; Index into the FX array.
    sra a
    ; Add `a` to `wRasterFX` and store in `hl`
    add a, LOW(wRasterFX)
    ld l, a
    adc a, HIGH(wRasterFX)
    sub a, l
    ld h, a 
    ld a, [hl]

    ; If no FX is loaded, exit!
    and a, a
    jp z, ExitStat

    ld b, b ; Error - invalid state
    jp ExitStat

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
    jr ExitStat

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

    ld a, [wTextboxPalsBank]
    swap_bank

    ld a, [wTextboxPalettes]
    ld h, a
    ld a, [wTextboxPalettes + 1]
    ld l, a
    ld a, [wTextboxFadeProgress]
    add a, a
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ld a, [hli]
    ld b, a
    ld c, [hl]

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

    ld a, b
    ldh [rBCPD], a
    ld a, c
    ldh [rBCPD], a
    ld a, SCREEN_HUD
    ldh [rLCDC], a
    ld a, 256 - (3*8) - 144
    ldh [rSCY], a
    xor a, a
    ldh [rSCX], a
    jr ExitStat

ExitStat:
    ; Restore register state
    ld a, [wInterruptBankBuffer]
    swap_bank
    pop hl
    pop bc
    pop af
    reti

SECTION "Stat Data", WRAM0

; Whether or not to use FX Mode. Requires rLYC to be reset to 1
wStatFXMode::
    ds 1

; An array of 80 bytes, each able to play an effect on every odd scan line.
wRasterFX::
    ds 160/2

; Single FX byte for regular STAT processing
wStaticFX::
    ds 1

; A pointer to the current text's precomputed palette design
wTextboxPalsBank::
    ds 1
wTextboxPalettes::
    ds 2
; How far along the palette design are we?
wTextboxFadeProgress::
    ds 1