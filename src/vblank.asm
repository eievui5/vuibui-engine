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
; Verticle Screen Blanking
VBlank:
    ; Save old bank so that we can restore it.
    ldh a, [hCurrentBank]
    ld [wVBlankBankBuffer], a

    ld a, SCREEN_NORMAL
    ldh [rLCDC], a

.dma
    ; push wShadowOAM to OAM though DMA
    ld a, high(wShadowOAM)
    call hOAMDMA

.pals
    ld a, [wPaletteState]
    and a, a
    call nz, UpdatePalettes

.tileRequests
    ld a, BANK(OctaviaUpdateSpellGraphic)
    swap_bank
    call OctaviaUpdateSpellGraphic

.metatileLoading
    call VBlankScrollLoader

.textbox
    call HandleTextbox

.scrolling
    ; Update screen scrolling here to avoid tearing. 
    ; This is low priority, but should happen at a point where the screen will not be torn.
    ; Smooth the screen scrolling, so that jumping between players is not jarring.
    ld a, [wSCXBuffer]
    ldh [rSCX], a
    ld a, [wSCYBuffer]
    ldh [rSCY], a

.input
    ; Updating Input should happen last, since it does not rely on VBlank
    call UpdateInput
    ; Delete me (debug button)
    ldh a, [hNewKeys]
    bit PADB_START, a
    jr z, .return
/*
    ld a, PALETTE_STATE_FADE_DARK
    ld [wPaletteState], a
*/
.return
    ; Let the main loop know a new frame is ready
    ld a, TRUE
    ld [wNewFrame], a

    ; Restore register state
    ld a, [wVBlankBankBuffer]
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
    ld [wSCXBuffer], a
.storeY
    ld a, e
    cp a, 256 - 144 + 16 + 1 ; Is A past the screen bounds?
    ret nc
    ld [wSCYBuffer], a
    ret



SECTION "VBlank Vars", WRAM0

wSCXBuffer::
    ds 1

wSCYBuffer::
    ds 1

wVBlankBankBuffer::
    ds 1