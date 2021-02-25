
include "include/hardware.inc"

SECTION "VBlank", ROM0
; Verticle Screen Blanking
VBlank::
    ; push wShadowOAM to OAM though DMA
    ld a, high(wShadowOAM)
    call hOAMDMA

    ; There is minimal room to load a few tiles here.

    ; Update screen scrolling here to avoid tearing. This is low priority.
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


SECTION "Scroll Buffer", WRAM0
wSCXBuffer::
    ds 1
wSCYBuffer::
    ds 1