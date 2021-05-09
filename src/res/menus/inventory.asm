
INCLUDE "include/bool.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/enum.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"

    start_enum TILE, $80
        enum CLEAR
        enum HOR_SEP
        enum VER_SEP
        enum JUNC_SEP
        ; Letters
        enum S, LETTERS
        enum a
        enum v
        enum e
        enum AND
        enum x
        enum i
        enum t
        enum C
        enum l
        enum o
        enum s
        ; Name letters
        enum O, P, T, NAME
        enum c, p, b
        enum y, r
    end_enum

SECTION "Inventory", ROMX

; The inventory uses custom selection logic so that it may have 2 dimensions.

InventoryHeader::
    db BANK("Inventory")
    dw InventoryInit
    ; Used Buttons
    db PADF_A | PADF_B | PADF_RIGHT | PADF_LEFT | PADF_UP | PADF_DOWN
    ; Auto-repeat
    db FALSE
    ; Button functions
    ; A, B, Sel, Start, Right, Left, Up, Down
    dw null, null, null, null, MoveRight, MoveLeft, MoveUp, MoveDown
    db 0 ; Last selected item
    ; Allow wrapping
    db FALSE
    ; Default selected item
    db 0
    ; Number of items in the menu
    db 2
    ; Redraw
    dw InventoryRedraw
    ; Private Items Pointer
    dw null
    ; Close Function
    dw null

InventoryInit:

; Fade out before we turn off the screen
    ld a, PALETTE_STATE_FADE_LIGHT
    ld [wPaletteState], a

.waitFade
    halt
    ld a, [wPaletteState]
    and a, a
    jr nz, .waitFade

    di
.waitVBlank
    ldh a, [rLY]
    cp a, SCRN_Y
    jr c, .waitVBlank

    xor a, a
    ldh [rLCDC], a

; Load inventory graphics
    ; Unpack seperators
    ld de, pb16_MenuSeperators
    get_tile hl, TILE_CLEAR
    ld b, 4
    call pb16_unpack_block

    ; Default letters
    ld hl, InventoryLetters
    get_tile de, TILE_LETTERS
    call LoadCharacters

    ld a, [wActivePlayer]
    ld b, a
    add a, b ; a * 2
    add a, b ; a * 3
    ld hl, OctaviaLetters
    add_r16_a hl
    ld de, TILE_NAME
    call LoadCharacters


; Reload palettes
    ld a, PALETTE_STATE_RESET
    ld [wPaletteState], a
    call UpdatePalettes

; Scroll to origin
    xor a, a
    ldh [hSCXBuffer], a
    ldh [hSCYBuffer], a
    ldh [rSCX], a
    ldh [rSCY], a

; Disable HUD
    ld [wStaticFX], a
    ld [wEnableHUD], a

    ld b, 10
    ld de, InventoryMap
    ld hl, _SCRN1 + (8 * 32) ; Skip 8 rows
    call ScreenCopy

; Reset OAM
    call ResetOAM

; Configure screen and display the inventory
    ld a, SCREEN_MENU
    ldh [hLCDCBuffer], a
    ldh [rLCDC], a

    reti

InventoryRedraw:
    ret

MoveRight:
    ret

MoveLeft:
    ret

MoveUp:
    ret

MoveDown:
    ret

InventoryMap:
    INCBIN "res/menus/inventory.tilemap"
.end

InventoryLetters:
    db "Save&xitClos", 0
OctaviaLetters:
    db "Oc ", 0
PoppyLetters:
    db "Ppy", 0
TiberLetters:
    db "Tbr", 0