INCLUDE "include/banks.inc"
INCLUDE "include/bool.inc"
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
    ; Save old bank so that we can restore it.
    ldh a, [hCurrentBank]
    ld [wInterruptBankBuffer], a

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

; Load tiles during screen transition
    call VBlankScrollLoader

; Draw the textbox during dialogue
    call HandleTextbox

; Check if octavia needs a new spell graphic.
    ld a, BANK(OctaviaUpdateSpellGraphic)
    swap_bank
    call OctaviaUpdateSpellGraphic

; Redraw the HUD and print function
    ld a, [wEnableHUD]
    and a, a
    jr z, .input
    call UpdateHUD
    call UpdatePrint

.input
    ; This should happen last, since it does not rely on VBlank
    call UpdateInput
    ; Delete me (debug button)
    ldh a, [hNewKeys]
    bit PADB_START, a
    jr z, .return

    ld a, BANK(TestPrintString)
    ld hl, TestPrintString
    call PrintNotification

.return

    ; Increment the global frame timer
    ld hl, wFrameTimer
    inc [hl]

    ; Let the main loop know a new frame is ready
    ld a, TRUE
    ld [wNewFrame], a

    ; Restore register state
    ld a, [wInterruptBankBuffer]
    swap_bank
    pop hl
    pop de
    pop bc
    pop af
    reti


; Stores de into the scroll buffers, making sure not to leave the screen bounds. Only a is used.
; @ d:  X
; @ e:  Y
SetScrollBuffer::
    ld a, d
    cp a, 256 - 160 + 1 ; Is A past the screen bounds?
    jr nc, .storeY
    ldh [hSCXBuffer], a
.storeY
    ld a, e
    cp a, 256 - 144 + 16 + 1 ; Is A past the screen bounds?
    ret nc
    ldh [hSCYBuffer], a
    ret



SECTION "VBlank Vars", WRAM0

wInterruptBankBuffer::
    ds 1

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