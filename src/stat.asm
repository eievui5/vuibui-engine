/* stat.asm
    FX and Stat interupts

    Stat is complicated and confusing, so this is split into two modes.

    Static mode jumps to a given FX when triggered. This is used for the HUD.
    Requires more fine control, but much less processor usage.

    The unused Raster Mode can play a given effect on every odd scan line, by
    using rLY to index into an array of scanline FX. Used for cutscenes or
    areas with low processor usage.

*/

INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/stat.inc"

SECTION "Stat Interrupt", ROM0[$48]
    ; Save register state
    push af
    push bc
    push hl
    jp Stat

SECTION "STAT Handler", ROM0

Stat:
    ld a, [wStatFXMode]
    and a, a
    jr nz, FXMode

    ld a, [wStaticFX]
    and a, a
    jr z, ShowHUD
    dec a
    jr z, PrintScroll

    ld b, b
    jr ExitStat


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
    ld hl, wRasterFX
    add_r16_a hl
    ld a, [hl]

    ; If no FX is loaded, exit!
    and a, a
    jr z, ExitStat

    ld b, b ; Error - invalid state
    jr ExitStat

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
    ; Wait for safe VRAM access
:   ld a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, SCREEN_HUD
    ldh [rLCDC], a
    ld a, 256 - (3*8) - 144
    ldh [rSCY], a
    ld a, [wHUDPrintScroll]
    ldh [rSCX], a

    ; Schedule another interrupt to undo this effect once needed
    ld a, STATIC_FX_SHOW_HUD
    ld [wStaticFX], a
    ld a, 144 - 16 - 1
    ldh [rLYC], a

    jr ExitStat

ExitStat:
    ; Restore register state
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