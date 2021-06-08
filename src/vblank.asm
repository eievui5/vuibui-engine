INCLUDE "include/banks.inc"
INCLUDE "include/directions.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/players.inc"
INCLUDE "include/text.inc"

SECTION "VBlank Interrupt", ROM0[$40]
    ; Save register state
    push af
    push bc
    push de
    push hl
    jp VBlank

SECTION "VBlank", ROM0
; Vertical Screen Blanking
VBlank:

    ldh a, [hLCDCBuffer]
    ldh [rLCDC], a

; OAM DMA
    ; push wShadowOAM to OAM though DMA
    ld a, high(wShadowOAM)
    call hOAMDMA

; Scroll
    ldh a, [hSCXBuffer]
    ldh [rSCX], a
    ldh a, [hSCYBuffer]
    ldh [rSCY], a

; Palettes
    ld a, [wPaletteState]
    and a, a
    call nz, UpdatePalettes

; These should be moved to the main thread!!!

; Load tiles during screen transition
    call VBlankScrollLoader

; Redraw the HUD and print function
    ld a, [wEnableHUD]
    and a, a
    jr z, .input
    call UpdatePrint

.input
    ; This should happen last, since it does not rely on VBlank
    call UpdateInput

    ; Increment the global frame timer
    ld hl, wFrameTimer
    inc [hl]

    ; Let the wait loops know a new frame is ready
    ld a, 1
    ld [wNewFrame], a

    ; Restore register state
    ldh a, [hCurrentBank]
    ld [rROMB0], a
    pop hl
    pop de
    pop bc
    pop af
    reti

SECTION "VBlank Vars", WRAM0

wInterruptBankBuffer::
    ds 1

; Used to store Gameplay scroll values during menus
wGameplaySC::
    .x::ds 1
    .y::ds 1

; Just a global frame timer
; Could be used for delays such as the health bar or for tracking playtime
wFrameTimer::
    ds 1

SECTION "Register Buffers", HRAM

hSCXBuffer::
    ds 1

hSCYBuffer::
    ds 1

hLCDCBuffer::
    ds 1