INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"

SECTION "Game Over menu", ROMX

xGameOverHeader::
    db BANK("Game Over menu")
    dw xGameOverInit
    ; Used Buttons
    db PADF_B
    ; Auto-repeat
    db 0
    ; Button functions
    dw null, null, null, null, null, null, null, null
    db 0 ; Last selected item
    ; Allow wrapping
    db 1
    ; Default selected item
    db 0
    ; Number of items in the menu
    db 2
    ; Redraw
    dw xGameOverRedraw
    ; Private Items Pointer
    dw 0
    ; Close Function
    dw Initialize

xGameOverInit:
    call CleanOAM
    xor a, a
    ld [wEnableHUD], a
    ld [wStaticFX], a
    ld bc, xGameOverTiles.end - xGameOverTiles
    ld de, $9000
    ld hl, xGameOverTiles
    call vmemcopy
    ld hl, $9800
    ld de, xGameOverMap
    ld b, 18
    call ScreenCopy
    xor a, a
    ldh [hSCXBuffer], a
    ldh [hSCYBuffer], a
    halt
    ld a, PALETTE_STATE_RESET
    ld [wPaletteState], a
    ;ret

xGameOverRedraw:
    xor a, a
    ldh [hSCXBuffer], a
    ldh [hSCYBuffer], a
    ret

xGameOverTiles:
    INCBIN "res/gfx/ui/gameover.2bpp"
.end

xGameOverMap:
    INCBIN "res/gfx/ui/gameover.tilemap"
.end