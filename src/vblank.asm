
include "include/hardware.inc"

SECTION "VBlank", ROM0
; Verticle Screen Blanking
VBlank::
    ; push wShadowOAM to OAM though DMA
    ld a, high(wShadowOAM)
    call hOAMDMA

    ; There is minimal room to load a few tiles here.

    ; Update screen scrolling here to avoid tearing. 
    ; This is low priority, but should happen at a point where the screen will not be torn.
    ; Smooth the screen scrolling, so that jumping between players is not jarring.
    ld a, [wSCXBuffer]
    ldh [rSCX], a
    ld a, [wSCYBuffer]
    ldh [rSCY], a

    ; Updating Input should happen last, since it does not rely on VBlank
    call UpdateInput

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
    cp a, 255 - 160 ; Is A past the screen bounds?
    jr nc, .storeY
    ld [wSCXBuffer], a
.storeY
    ld a, e
    cp a, 255 - 144 ; Is A past the screen bounds?
    ret nc
    ld [wSCYBuffer], a
    ret


SECTION "Scroll Buffer", WRAM0
wSCXBuffer::
    ds 1
wSCYBuffer::
    ds 1