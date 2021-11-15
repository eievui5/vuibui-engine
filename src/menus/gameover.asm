INCLUDE "engine.inc"
INCLUDE "graphics.inc"
INCLUDE "hardware.inc"
INCLUDE "optimize.inc"

SECTION "Game Over menu", ROMX

xGameOverHeader::
    DB BANK("Game Over menu")
    DW xGameOverInit
    ; Used Buttons
    DB PADF_B
    ; Auto-repeat
    DB 0
    ; Button functions
    DW null, xHandleBPress, null, null, null, null, null, null
    DB 0 ; Last selected item
    ; Allow wrapping
    DB 1
    ; Default selected item
    DB 0
    ; Number of items in the menu
    DB 2
    ; Redraw
    DW null
    ; Private Items Pointer
    DW null
    ; Close Function
    DW Initialize

xGameOverInit:
    call CleanOAM
    xor a, a
    ld [wEnableHUD], a
    ld [wStaticFX], a
    ld bc, xGameOverTiles.end - xGameOverTiles
    ld de, $9000
    ld hl, xGameOverTiles
    call VRAMCopy
    ld hl, $9800
    ld de, xGameOverMap
    ld b, 18
    call ScreenCopy
    ; Set DMG Pal state, overwrite it if on CGB
    ld a, PALETTE_STATE_RESET
    ld [wPaletteState], a
    ; Do CGB stuff.
    ldh a, [hSystem]
    and a, a
    jr z, .skipCgb
        ; Set screen to palette 0
        ld a, 1
        ldh [rVBK], a
        ld hl, $9800
        lb bc, 0, 18
        call ScreenSet
        xor a, a
        ldh [rVBK], a
        ; Set palettes and fade.
        ld de, wBCPDTarget
        ld hl, xGameOverPal
        ld c, sizeof_PALETTE
        rst MemCopySmall
        ld a, PALETTE_STATE_FADE
        ld [wPaletteState], a
.skipCgb
    xor a, a
    ldh [hSCXBuffer], a
    ldh [hSCYBuffer], a
    ret

xHandleBPress:
    ld a, $FF
    ld hl, wBCPDTarget
    ld c, sizeof_PALETTE
    rst MemSetSmall
    ld a, PALETTE_STATE_FADE_LIGHT
    ld [wPaletteState], a
.waitFade
    halt
	ld a, [wPaletteState]
	and a, a
	jr nz, .waitFade
    ret

xGameOverTiles:
    INCBIN "res/gfx/ui/gameover.2bpp"
.end

xGameOverMap:
    INCBIN "res/gfx/ui/gameover.tilemap"
.end

xGameOverPal:
    rgb 24, 0, 20
    rgb 12, 0, 9
    rgb 5, 0, 3
    rgb 2, 0, 1
