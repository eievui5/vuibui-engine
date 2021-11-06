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
    ldh a, [hCurrentBank]
    ld [wInterruptBankBuffer], a

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

.input
    call UpdateInput
    call audio_update
    ld hl, wFrameTimer
    inc [hl]

    ; Let the wait loops know a new frame is ready
    ld a, 1
    ld [wNewFrame], a

    ; Restore register state
    ld a, [wInterruptBankBuffer]
    rst SwapBank
    pop hl
    pop de
    pop bc
    pop af
    reti

SECTION "VBlank Vars", WRAM0

wInterruptBankBuffer::
    DS 1

; Used to store Gameplay scroll values during menus
wGameplaySC::
    .x::ds 1
    .y::ds 1

; Just a global frame timer
; Could be used for delays such as the health bar or for tracking playtime
wFrameTimer::
    DS 1

SECTION "Register Buffers", HRAM

hSCXBuffer::
    DS 1

hSCYBuffer::
    DS 1

hLCDCBuffer::
    DS 1