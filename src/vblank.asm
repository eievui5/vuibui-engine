
INCLUDE "include/directions.inc"
include "include/hardware.inc"
include "include/engine.inc"
include "include/text.inc"
INCLUDE "include/players.inc"

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

    ; There is minimal room to load a few tiles here.

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

    ; debug....
/*
    ld a, -2
    ld [wOctavia_YVel], a
    ld [wPoppy_YVel], a
    ld [wTiber_YVel], a
    ld a, -0
    ld [wOctavia_XVel], a
    ld [wPoppy_XVel], a
    ld [wTiber_XVel], a
    ld a, $01
    ld [wOctavia_CollisionData], a
    ld [wPoppy_CollisionData], a
    ld [wTiber_CollisionData], a
*/
.return

    ; Let the main loop know a new frame is ready
    ld a, 1 
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


SECTION "VBlank Vars", WRAM0

wSCXBuffer::
    ds 1

wSCYBuffer::
    ds 1