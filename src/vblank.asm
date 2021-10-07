INCLUDE "banks.inc"
INCLUDE "directions.inc"
INCLUDE "engine.inc"
INCLUDE "hardware.inc"
INCLUDE "players.inc"
INCLUDE "text.inc"

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
    ld a, HIGH(wShadowOAM)
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
    call nz, UpdatePrint
    ; Fallthrough
.input
    call UpdateInput
    call audio_update
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