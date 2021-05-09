
INCLUDE "include/banks.inc"
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
        ; Pointer
        enum POINTER_ALIGN ; sprites are in 8*16 mode, align pointer
        enum POINT
        enum POINT2
        enum SELECTION
    end_enum

DEF COLUMN_1 EQU %10000000

SECTION "Inventory", ROM0

; The inventory uses custom selection logic so that it may have 2 dimensions.
; SelectedItem treats bit 7 as the column, and the lower bits are used for 
; vertical position

InventoryHeader::
    db BANK("Inventory")
    dw InventoryInit
    ; Used Buttons
    db PADF_A | PADF_B | PADF_RIGHT | PADF_LEFT | PADF_UP | PADF_DOWN
    ; Auto-repeat
    db FALSE
    ; Button functions
    ; A, B, Sel, Start, Right, Left, Up, Down
    dw HandleAPress, null, null, null, MoveRight, MoveLeft, MoveUp, MoveDown
    db 0 ; Last selected item
    ; Allow wrapping
    db FALSE
    ; Default selected item
    db $80 ; Temporarily set to second column
    ; Number of items in the menu
    db 2
    ; Redraw
    dw InventoryRedraw
    ; Private Items Pointer
    dw null
    ; Close Function
    dw InventoryClose

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
    ld a, BANK(pb16_MenuSeperators)
    swap_bank
    ld de, pb16_MenuSeperators
    get_tile hl, TILE_CLEAR
    ld b, 4
    call pb16_unpack_block

    ; Default letters
    ld a, BANK(InventoryLetters)
    swap_bank
    ld hl, InventoryLetters
    get_tile de, TILE_LETTERS
    call LoadCharacters

    ; Load the active player's letters
    ld a, [wActivePlayer]
    ; Each entry is 4 bytes, include the 0-terminator.
    add a, a ; a * 2
    add a, a ; a * 4
    ld hl, OctaviaLetters
    add_r16_a hl
    get_tile de, TILE_NAME
    call LoadCharacters

    ld a, BANK(obpp_Pointer)
    ld hl, obpp_Pointer
    get_tile de, TILE_POINT
    ld c, 8
    call Unback1bppBanked
    
    ld a, BANK(obpp_ItemSelection)
    ld hl, obpp_ItemSelection
    get_tile de, TILE_SELECTION
    ld c, 16
    call Unback1bppBanked

; Reload palettes
    ld a, PALETTE_STATE_RESET
    call UpdatePalettes

; Scroll to origin

    ; Store current scroll values
    ldh a, [hSCXBuffer]
    ld [wGameplaySC.x], a
    ldh a, [hSCYBuffer]
    ld [wGameplaySC.y], a

    xor a, a
    ldh [hSCXBuffer], a
    ldh [hSCYBuffer], a
    ldh [rSCX], a
    ldh [rSCY], a

; Disable HUD
    ld [wStaticFX], a
    ld [wEnableHUD], a

; Reset doll variables
    ld [wPlayerDollDirection], a
    ld [wPlayerDollTimer], a

; Reset OAM
    call ResetOAM

; Draw the screen
    ld b, 10
    ld a, BANK(InventoryMap)
    swap_bank
    ld de, InventoryMap
    ld hl, _SCRN1 + (8 * 32) ; Skip 8 rows
    call ScreenCopy

    ; Load the player's name onto the screen.
    ; Each name is padded to 7 bytes
    ld a, [wActivePlayer]
    ld b, a
    add a, a ; a * 2
    add a, a ; a * 4
    add a, a ; a * 8
    sub a, b ; a * 7 !!!
    ld hl, OctaviaString
    add_r16_a hl
    get_tilemap de, _SCRN1, 9, 9
    ld c, 7
    rst memcopy_small

; Configure screen and display the inventory
    ld a, SCREEN_MENU
    ldh [hLCDCBuffer], a
    ldh [rLCDC], a

    reti

InventoryRedraw:
    xor a, a
    ldh [hOAMIndex], a
    ldh [hRenderByte], a

; Render player doll
    ; Get the active player's metasprites
    ld a, [wActivePlayer]
    ld b, a
    add a, a ; a * 2
    add a, b ; a * 3 !!!
    ld hl, .metaspriteLookup
    add_r16_a hl
    ld a, [hli]
    swap_bank
    ld a, [hli]
    ld h, [hl]
    ld l, a

    ld a, [wPlayerDollTimer]
    inc a
    ld [wPlayerDollTimer], a
    jr z, .directionIncrement
    and a, %100000
    jr nz, .renderDoll
    ld a, 8
    add_r16_a hl
    jr .renderDoll
.directionIncrement
    ld a, [wPlayerDollDirection]
    add a, 2
    cp a, 4
    jr c, .storeDirection
    jr z, :+
    xor a, a
    jr .storeDirection
:   ld a, 1
.storeDirection
    ld [wPlayerDollDirection], a

.renderDoll
    ld a, [wPlayerDollDirection]
    add a, a ; a * 2
    add_r16_a hl

    ld a, [hli]
    ld h, [hl]
    ld l, a

    lb bc, (10*8) + 16, (8*8) + 8
    call RenderMetasprite.absolute

; Handle Cursor
    ; Grab the UI pointer off the stack.
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    dec hl
    dec hl
    dec hl

    ; Save selection in `b`
    ld b, [hl]
    bit 7, [hl]
    jr nz, .options ; if bit 7 is set, 

    ret

.options

    ldh a, [hOAMIndex]
    ld hl, wShadowOAM + 4
    add_r16_a hl

    ld a, b
    add a, a ; Selection * 2
    add a, a ; Selection * 4
    add a, a ; Selection * 8
    add a, a ; Selection * 16 !!!
    add a, (12*8) + 16 ; offset to options
    ld [hli], a ; store YPos

    ld a, (8*8) + 4 ; Static XPos
    ld [hli], a ; Store XPos

    ld a, TILE_POINT
    ld [hli], a ; Store Tile

    xor a, a
    ld [hli], a ; Store attirbutes

    ldh a, [hOAMIndex]
    add a, 4
    ldh [hOAMIndex], a

    ret

.metaspriteLookup
    far_pointer OctaviaMetasprites
    far_pointer PoppyMetasprites
    far_pointer TiberMetasprites

InventoryClose:
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

    call ReloadMapGraphics

    ld a, [wGameplaySC.x]
    ldh [hSCXBuffer], a
    ldh [rSCX], a
    ld a, [wGameplaySC.y]
    ldh [hSCYBuffer], a
    ldh [rSCY], a

    ld a, TRUE
    ld [wEnableHUD], a
    call ResetHUD

    call ResetOAM

    ASSERT ENGINE_STATE_GAMEPLAY == 0
    xor a, a
    ldh [hEngineState], a

    ld a, SCREEN_NORMAL
    ldh [hLCDCBuffer], a
    ldh [rLCDC], a

    ei

    ret

MoveRight:
    xor a, a
    ld [wMenuAction], a
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; Allow Wrapping
    ret

MoveLeft:
    xor a, a
    ld [wMenuAction], a
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; Allow Wrapping
    ret

MoveUp:
    xor a, a
    ld [wMenuAction], a
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; Allow Wrapping
    inc hl ; SelectedItem
    ld a, [hl]
    and a, a
    ret z ; No wrapping!
    cp a, 0 | COLUMN_1
    ret z ; No wrapping!
    dec [hl]
    ret

MoveDown:
    xor a, a
    ld [wMenuAction], a
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; Allow Wrapping
    inc hl ; SelectedItem

    ld a, 3
    bit 7, [hl]
    jr z, .items
    ; options has a max Y of 3
    ld a, 2 | COLUMN_1
.items
    cp a, [hl]
    ret z
    inc [hl]
    ret

HandleAPress:
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; Allow Wrapping
    inc hl

    ld a, [hl]
    cp a, 0 | COLUMN_1
    ret z

    xor a, a
    ld [wMenuAction], a
    ret

SECTION "Inventory Data", ROMX, BANK[2]

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

; These must be 7 bytes.
OctaviaString:
    db TILE_O, TILE_c, TILE_t, TILE_a, TILE_v, TILE_i,     TILE_a
PoppyString:
    db TILE_P, TILE_o, TILE_p, TILE_p, TILE_y, TILE_CLEAR, TILE_CLEAR
TiberString:
    db TILE_T, TILE_i, TILE_b, TILE_e, TILE_r, TILE_CLEAR, TILE_CLEAR

SECTION "Inventory Variables", WRAM0

; Which direction is the doll facing?
wPlayerDollDirection:
    ds 1
; Step and directory timer
wPlayerDollTimer:
    ds 1