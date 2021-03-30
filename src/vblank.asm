
INCLUDE "include/bool.inc"
INCLUDE "include/directions.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/players.inc"
INCLUDE "include/switch.inc"
INCLUDE "include/text.inc"

SECTION "VBlank Interrupt", ROM0[$40]
    ; Save register state
    push af
    push bc
    push de
    push hl
    jp VBlank

SECTION "Stat Interrupt", ROM0[$48]
    ; Save register state
    push af
    push bc
    push de
    push hl
    jp Stat

SECTION "VBlank", ROM0
; Verticle Screen Blanking
VBlank:

    ld a, SCREEN_NORMAL
    ldh [rLCDC], a

.dma
    ; push wShadowOAM to OAM though DMA
    ld a, high(wShadowOAM)
    call hOAMDMA

    ld a, [wPaletteState]
    and a, a
    call nz, UpdatePalettes

.tileRequests
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
    pop hl
    pop de
    pop bc
    pop af
    reti


Stat:

    ld a, SCREEN_WINDOW
    ldh [rLCDC], a

    ; Restore register state
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

UpdatePalettes::
    ld b, a
    ld a, [wPaletteTimer]
    inc a
    ld [wPaletteTimer], a
    bit 0, a
    ret z
    ld a, b
    dec a
    switch
        case PALETTE_STATE_FADE_DARK - 1, .fadeDark
        case PALETTE_STATE_FADE_LIGHT - 1, .fadeLight
        case PALETTE_STATE_RESET - 1, .reset
    end_switch

.fadeDark
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
.fadeLight
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
.reset
    ld a, [wBGP]
    ldh [rBGP], a
    ld a, [wOBP0]
    ldh [rOBP0], a
    ld a, [wOBP1]
    ldh [rOBP1], a
    ret

SECTION "VBlank Vars", WRAM0

wSCXBuffer::
    ds 1

wSCYBuffer::
    ds 1

wPaletteState::
    ds 1
wPaletteTimer:
    ds 1
wPaletteInterp:
    ds 1

; Used to restore colors to a set of values after a fade.
wBGP::
    ds 1
wOBP0::
    ds 1
wOBP1::
    ds 1

/*
wCurrentPalette::
.cgbBGP
    ds 8 * 3
.cgbOBJ
    ds 8 * 3

; The engine uses a second palette buffer for interpolating into the target color.
wPaletteTarget::
.cgbBGP
    ds 8 * 3
.cgbOBJ
    ds 8 * 3
*/
/*
DARK

%11111111
%11111110
%11111001
%11100100

LIGHT

%00000000
%01000000
%10010000
%11100100
*/