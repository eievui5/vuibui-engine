
INCLUDE "banks.inc"
INCLUDE "engine.inc"
INCLUDE "enum.inc"
INCLUDE "graphics.inc"
INCLUDE "hardware.inc"
INCLUDE "map.inc"
INCLUDE "menu.inc"
INCLUDE "optimize.inc"
INCLUDE "vdef.inc"

    dtile_section $8800

    dtile vHSeperator
    dtile vJunctionSeperator
    dtile vBlankTile
    dtile vVSeperator
    dtile_align
    dtile vPointerCursor, 2
    dtile vSelectionCursor, 2
    dtile vItem0, 4
    dtile vItem1, 4
    dtile vItem2, 4
    dtile vItem3, 4
    dtile vDash
    dtile vHint, 4
    dtile vCloseText, STRLEN("Close")
    dtile vSaveText, STRLEN("Save")
    dtile vAndExitText, STRLEN("Save & Exit")
    dtile vPlayerName, STRLEN("Octavia")

DEF COLUMN_1 EQU %10000000
DEF UI_PAL EQU 6
DEF SEL_PAL EQU 7

SECTION "Inventory", ROM0
; The inventory uses custom selection logic so that it may have 2 dimensions.
; SelectedItem treats bit 7 as the column, and the lower bits are used for
; vertical position

InventoryHeader::
    DB BANK("Inventory")
    DW InventoryInit
    ; Used Buttons
    DB PADF_A | PADF_B | PADF_SELECT | PADF_START | PADF_RIGHT | PADF_LEFT | PADF_UP | PADF_DOWN
    ; Auto-repeat
    DB 0
    ; Button functions
    ; A, B, Sel, Start, Right, Left, Up, Down
    DW HandleAPress, HandleBPress, HandleStartPress, HandleStartPress, MoveRight, MoveLeft, MoveUp, MoveDown
    DB 0 ; Last selected item
    ; Allow wrapping
    DB 0
    ; Default selected item
    DB 0
    ; Number of items in the menu
    DB 2
    ; Redraw
    DW InventoryRedraw
    ; Private Items Pointer
    DW null
    ; Close Function
    DW InventoryClose

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
    ld a, BANK(InventoryGraphics)
    rst SwapBank
    ld c, InventoryGraphics.end - InventoryGraphics
    ld de, vHSeperator
    ld hl, InventoryGraphics
    call VRAMCopySmall

    lb bc, BANK(obpp_Pointer), 8
    ld de, vPointerCursor
    ld hl, obpp_Pointer
    call Unpack1bppBanked
    lb bc, 0, 16
    ld hl, vPointerCursor + 16
    call VRAMSetSmall

    lb bc, BANK(obpp_ItemSelection), 16
    ld de, vSelectionCursor
    ld hl, obpp_ItemSelection
    call Unpack1bppBanked

    ; Load a line into VRAM to use as a dash
    lb bc, 0, 16
    ld hl, vDash
    call VRAMSetSmall
    ld a, %01111110
    ld [vDash + 16-2], a
    ld [vDash + 16-1], a

    ; Load the player's items
    ld a, BANK("Item Icons")
    rst SwapBank

    ; Load the button hints
    ld c, GfxButtons.end - GfxButtons
    ld de, vHint
    ld hl, GfxButtons
    call VRAMCopySmall

    ld a, [wActivePlayer]
    and a, a
    jr z, .octaviaItems
    dec a
    jr z, .poppyItems

; Tiber items
    ld hl, GfxSwordIcon
    jr .loadItems

.poppyItems
    ld hl, GfxBow
    jr .loadItems

.octaviaItems
    ld hl, GfxFireSpell

.loadItems
    ASSERT sizeof_TILE * 4 * 4 == 256
    ld c, 0 ; 0 is 256 bytes.
    ld de, vItem0
    call VRAMCopySmall

    ; Load palettes on CGB
    ldh a, [hSystem]
    and a, a
    jr z, .cgbSkip

    ld hl, PalGrey
    ld de, wBCPD + sizeof_PALETTE * 6
    ld c, sizeof_PALETTE
    rst MemCopySmall

    ld a, [wActivePlayer]
    ASSERT sizeof_PALETTE == 12
    add a, a ; a * 2
    add a, a ; a * 4
    ld c, a
    add a, a ; a * 8
    add a, c ; a * 12
    ; Add `a` to `PalOctavia` and store in `hl`
    add a, LOW(PalOctavia)
    ld l, a
    adc a, HIGH(PalOctavia)
    sub a, l
    ld h, a
    ld c, sizeof_PALETTE
    rst MemCopySmall

    ; Load player pals
    lb bc, BANK(PalPlayers), sizeof_PALETTE * 4
    ld de, wOCPD
    ld hl, PalPlayers
    call MemCopyFar

.cgbSkip
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
    ld [wLastSelectedItem], a
    ; Disable HUD
    ld [wStaticFX], a
    ld [wEnableHUD], a
    ; Reset doll variables
    ld [wPlayerDollDirection], a
    ld [wPlayerDollTimer], a
;    Reset OAM
    call ResetOAM

    ; Draw the screen
    ; Reset pals
    ld a, 1
    ldh [rVBK], a
    lb bc, UI_PAL, 10 ; 10 rows
    ld hl, _SCRN1 + (8 * 32) ; Skip 8 rows
    call ScreenSet
    xor a, a
    ldh [rVBK], a

    ld b, 10
    ld a, BANK(InventoryMap)
    rst SwapBank
    ld de, InventoryMap
    ld hl, _SCRN1 + (8 * 32) ; Skip 8 rows
    call ScreenCopy

    ld a, BANK(Text)
    rst SwapBank
    ld a, idof_vCloseText
    ldh [hDrawStringTileBase], a
    ld de, vCloseText

    ld bc, Text.close
    get_tilemap hl, _SCRN1, 9, 12
    call DrawString
    ld bc, Text.save
    get_tilemap hl, _SCRN1, 9, 14
    call DrawString
    ld bc, Text.saveAndExit
    get_tilemap hl, _SCRN1, 9, 16
    call DrawString

    ; Load the player's name onto the screen.
    ld a, [wActivePlayer]
    and a, a
    jr z, :+
    dec a
    jr z, :++
    ld bc, Text.tiber
    jr :+++
:   ld bc, Text.octavia
    jr :++
:   ld bc, Text.poppy

:   get_tilemap hl, _SCRN1, 9, 9
    call DrawString

    ; Lookup the active map's panorama
    ld a, [wActiveWorldMap]
    ld b, a
    add a, a
    add a, b
    ; Add `a` to `PanoramaLookup` and store in `hl`
    add a, LOW(PanoramaLookup)
    ld l, a
    adc a, HIGH(PanoramaLookup)
    sub a, l
    ld h, a

    ; Load the active map's panorama
    ld a, [hli]
    rst SwapBank
    ld a, [hli]
    ld h, [hl]
    ld l, a

    ldh a, [hSystem]
    and a, a
    jr z, .skipColorOffset
    ; Offset to CGB stuff
    ld a, Panorama_CGBTiles
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

.skipColorOffset
    ; Load the active map's panorama's tiles
    ld a, [hli]
    push hl
        ld bc, sizeof_TILE * 64
        ld de, _VRAM_BG
        ld h, [hl]
        ld l, a
        call VRAMCopy
    pop hl
    inc hl

    ; Load the active map's panorama's map
    ld a, [hli]
    push hl
        ld d, [hl]
        ld e, a
        ld hl, _SCRN1
        ld b, 8 ; 8 rows.
        call ScreenCopy
    pop hl
    inc hl

    ldh a, [hSystem]
    and a, a
    jr z, .cgbPanSkip

    ; Load the active map's panorama's attributes
    ld a, 1
    ldh [rVBK], a
    ld a, [hli]
    push hl
        ld d, [hl]
        ld e, a
        ld hl, _SCRN1
        ld b, 8 ; 8 rows.
        call ScreenCopy
    pop hl
    inc hl
    xor a, a
    ldh [rVBK], a

    ; Load the active map's panorama's palettes
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld de, wBCPD
    ld c, sizeof_PALETTE * 6
    rst MemCopySmall

.cgbPanSkip
    ; Both systems need this reset
    ld a, PALETTE_STATE_RESET
    call UpdatePalettes

    ; Display the player's items on screen
    ld a, [wActivePlayer]
    ; Add `a` to `wItems` and store in `hl`
    add a, LOW(wItems)
    ld l, a
    adc a, HIGH(wItems)
    sub a, l
    ld h, a
    ld b, [hl]

    ; Item 0
    bit 0, b
    jr z, .item1
    get_tilemap hl, _SCRN1, 1, 9
    ld a, idof_vItem0
    ld [hli], a
    inc a
    ld [hli], a
    get_tilemap hl, _SCRN1, 1, 10
    inc a
    ld [hli], a
    inc a
    ld [hli], a

.item1
    bit 1, b
    jr z, .item2
    get_tilemap hl, _SCRN1, 1, 11
    ld a, idof_vItem1
    ld [hli], a
    inc a
    ld [hli], a
    get_tilemap hl, _SCRN1, 1, 12
    inc a
    ld [hli], a
    inc a
    ld [hli], a

.item2
    bit 2, b
    jr z, .item3
    get_tilemap hl, _SCRN1, 1, 13
    ld a, idof_vItem2
    ld [hli], a
    inc a
    ld [hli], a
    get_tilemap hl, _SCRN1, 1, 14
    inc a
    ld [hli], a
    inc a
    ld [hli], a

.item3
    bit 3, b
    jr z, .exit
    get_tilemap hl, _SCRN1, 1, 15
    ld a, idof_vItem3
    ld [hli], a
    inc a
    ld [hli], a
    get_tilemap hl, _SCRN1, 1, 16
    inc a
    ld [hli], a
    inc a
    ld [hli], a

.exit
    ; Configure screen and display the inventory
    ld a, SCREEN_MENU
    ldh [hLCDCBuffer], a
    ldh [rLCDC], a
    reti

InventoryRedraw:
    call CleanOAM
    xor a, a
    ldh [hRenderByte], a

    call DrawEquipped

    ; Highlight the selected item on CGB
    ldh a, [hSystem]
    and a, a
    jr z, .cgbSkip

    ; Grab the UI pointer off the stack.
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    dec hl
    dec hl
    dec hl

    bit 7, [hl]
    jr nz, .cgbSkip ; Skip if we're on the wrong column

    ld a, 1
    ldh [rVBK], a

    ld b, 8
    get_tilemap hl, _SCRN1, 1, 9

.cleanAttributesLoop
    ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, .cleanAttributesLoop

    ld a, UI_PAL
    ld [hli], a
    ld [hl], a

    ld a, 31
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    dec b
    jr nz, .cleanAttributesLoop

    ; Grab the UI pointer off the stack.
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    dec hl
    dec hl
    dec hl

    ld a, [hl] ; grab and offset selection
    swap a ; a * 16
    add a, a ; a * 32
    add a, a ; a * 64
    get_tilemap hl, _SCRN1, 1, 9
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, SEL_PAL
    ld [hli], a
    ld [hl], a

    ld a, 31
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, SEL_PAL
    ld [hli], a
    ld [hl], a

    xor a, a
    ldh [rVBK], a

.cgbSkip
    ; Render player doll
    ; Get the active player's metasprites
    ld a, [wActivePlayer]
    ld b, a
    add a, a ; a * 2
    add a, b ; a * 3 !!!
    ; Add `a` to `.metaspriteLookup` and store in `hl`
    add a, LOW(.metaspriteLookup)
    ld l, a
    adc a, HIGH(.metaspriteLookup)
    sub a, l
    ld h, a
    ld a, [hli]
    rst SwapBank
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
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
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
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

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
    ; Otherwise, draw the item cursor.
    ldh a, [hOAMIndex]
    add a, 4
    ld l, a
    ld h, HIGH(wShadowOAM + 4)

    ld a, b
    swap a ; a * 16
    add a, 9 * 8 + 16 ; Offset to item list
    ld [hli], a
    ld a, 1 * 8 + 8 - 1
    ld [hli], a
    ld a, idof_vSelectionCursor
    ld [hli], a
    xor a, a
    ld [hli], a

    ld a, b
    swap a ; a * 16
    add a, 9 * 8 + 16 ; Offset to item list
    ld [hli], a
    ld a, 2 * 8 + 8 + 1
    ld [hli], a
    ld a, idof_vSelectionCursor
    ld [hli], a
    ld a, OAMF_XFLIP
    ld [hli], a

    ldh a, [hOAMIndex]
    add a, 8
    ldh [hOAMIndex], a
    ret

.options
    ldh a, [hOAMIndex]
    add a, 4
    ld l, a
    ld h, HIGH(wShadowOAM)

    ld a, b
    add a, a ; Selection * 2
    add a, a ; Selection * 4
    add a, a ; Selection * 8
    add a, a ; Selection * 16 !!!
    add a, (12*8) + 16 ; offset to options
    ld [hli], a ; store YPos

    ld a, (8*8) + 4 ; Static XPos
    ld [hli], a ; Store XPos

    ld a, idof_vPointerCursor
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
    ld a, $FF
    ld bc, sizeof_PALETTE * 16
    ld hl, wBCPDTarget
    rst MemSetSmall
    ; Fade out before we turn off the screen
    ld a, PALETTE_STATE_FADE_LIGHT
    ld [wPaletteState], a

.waitFade
    halt
    ld a, [wPaletteState]
    and a, a
    jr nz, .waitFade

    call ReloadMapGraphics

    ld a, [wGameplaySC.x]
    ldh [hSCXBuffer], a
    ldh [rSCX], a
    ld a, [wGameplaySC.y]
    ldh [hSCYBuffer], a
    ldh [rSCY], a
    ld a, 1
    ld [wEnableHUD], a
    call ResetHUD
    call CleanOAM
    ASSERT ENGINE_STATE_GAMEPLAY == 0
    xor a, a
    ldh [hEngineState], a
    ld a, SCREEN_NORMAL
    ldh [hLCDCBuffer], a
    reti

MoveRight:
    xor a, a
    ld [wMenuAction], a
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; Allow Wrapping
    inc hl ; SelectedItem
    bit 7, [hl]
    ret nz
    ld a, [hl]
    ld [wLastSelectedItem], a
    ld a, 0 | COLUMN_1
    ld [hl], a
    ret

MoveLeft:
    xor a, a
    ld [wMenuAction], a
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; Allow Wrapping
    inc hl ; SelectedItem
    bit 7, [hl]
    ret z
    ld a, [wLastSelectedItem]
    ld [hl], a
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
    ld b, [hl]

    ; options has a max Y of 3
    ld a, 2 | COLUMN_1
    bit 7, b
    jr nz, .skipItems
    ; Items goes up to 4 depending on how many items are unlocked.
    ld a, [wActivePlayer]
    ; Add `a` to `wItems` and store in `hl`
    add a, LOW(wItems)
    ld l, a
    adc a, HIGH(wItems)
    sub a, l
    ld h, a
    ; Check each item slot
    ld a, 3
    bit 3, [hl]
    jr nz, .skipItems
    dec a
    bit 2, [hl]
    jr nz, .skipItems
    dec a
    bit 1, [hl]
    jr nz, .skipItems
    dec a
.skipItems
    cp a, b
    ret z
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; Allow Wrapping
    inc hl ; SelectedItem
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
    ret z ; Exit menu if on the first option
    cp a, 1 | COLUMN_1
    jr z, .save ; Or save the game to SRAM.
    cp a, 2 | COLUMN_1
    jr z, .saveAndExit ; Or exit to the title!
    bit 7, a
    jr nz, .exit ; Do nothing else (yet) if on the second column

    ; Save the target item in c
    ld c, [hl]
    inc c

    ; Otherwise, select an item.
    ld a, [wActivePlayer]
    ; Add `a` to `wPlayerEquipped` and store in `de`
    add a, LOW(wPlayerEquipped)
    ld e, a
    adc a, HIGH(wPlayerEquipped)
    sub a, e
    ld d, a

    ld a, [de]
    and a, $0F ; Mask out old B item
    cp a, c ; Check if old A item is the same as new A item
    jr nz, .notInA
    ; If the new A item matches old A, clear A
    ld a, [de]
    and a, $F0
    ld [de], a
    jr .exit

.notInA
    ld a, [de]
    and a, $F0 ; Mask out old A item
    swap a
    cp a, c ; If new A matches old B, clear B
    jr nz, .notInB
    ld a, c
    ld [de], a
    jr .exit

.notInB
    ld a, [de]
    and a, $F0 ; Mask out the old A value
    or a, c ; combine old A and new B
    ld [de], a

.exit
    ; Was that item unlocked?
    and a, $0F
    dec a
    call GetBitA
    ld b, a

    ld a, [wActivePlayer]
    ; Add `a` to `wItems` and store in `hl`
    add a, LOW(wItems)
    ld l, a
    adc a, HIGH(wItems)
    sub a, l
    ld h, a

    ld a, b
    and a, [hl]
    jr nz, .gotItem

    ; No? Reset it!
    ld a, [de]
    and a, $F0
    ld [de], a

.gotItem
    xor a, a
    ld [wMenuAction], a
    ret

.save
    ld b, BANK(xStoreSaveFile)
    ld de, sSave0
    ld hl, xStoreSaveFile
    rst FarCall
    ret

.saveAndExit
    call .save
    ld a, $FF
    ld bc, sizeof_PALETTE * 16
    ld hl, wBCPDTarget
    rst MemSetSmall
    ; Fade out before we turn off the screen
    ld a, PALETTE_STATE_FADE_LIGHT
    ld [wPaletteState], a

.waitFade
    halt
    ld a, [wPaletteState]
    and a, a
    jr nz, .waitFade
    jp Initialize

HandleBPress:
    ld hl, sp+2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; Allow Wrapping
    inc hl

    ; Close if on the second column
    bit 7, [hl]
    ret nz

    ; Save the target item in c
    ld c, [hl]
    inc c

    ; Otherwise, select an item.
    ld a, [wActivePlayer]
    ; Add `a` to `wPlayerEquipped` and store in `de`
    add a, LOW(wPlayerEquipped)
    ld e, a
    adc a, HIGH(wPlayerEquipped)
    sub a, e
    ld d, a

    ld a, [de]
    and a, $0F ; Mask out old B item
    cp a, c ; Check if old A item is the same as new B item
    jr nz, .notInA
    ; If the new B item matches old A, overwrite A
    ld a, c
    swap a
    ld [de], a
    jr .exit

.notInA
    ld a, [de]
    and a, $F0 ; Mask out old A item
    swap a ; Push B into the lower nibbel
    cp a, c ; If new B matches old B, clear B
    jr nz, .notInB
    ; If this item is already in B, clear B
    ld a, [de]
    and a, $0F
    ld [de], a
    jr .exit

.notInB
    ld a, [de]
    and a, $0F ; Mask out the old B value
    swap c ; Move new B to the upper nibble
    or a, c ; combine old A and new B
    ld [de], a

.exit
    ; Was that item unlocked?
    and a, $F0
    swap a
    dec a
    call GetBitA
    ld b, a

    ld a, [wActivePlayer]
    ; Add `a` to `wItems` and store in `hl`
    add a, LOW(wItems)
    ld l, a
    adc a, HIGH(wItems)
    sub a, l
    ld h, a

    ld a, b
    and a, [hl]
    jr nz, .gotItem

    ; No? Reset it!
    ld a, [de]
    and a, $0F
    ld [de], a

.gotItem
    xor a, a
    ld [wMenuAction], a
    ret

HandleStartPress:
    ld a, MENU_CANCELLED
    ld [wMenuClosingReason], a
    ret

; Redraw equipped items each frame
DrawEquipped:
    get_tilemap hl, _SCRN1, 3, 9
    ld b, 4
.cleanLoop
:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, idof_vBlankTile
    ld [hli], a
    ld [hl], a
    ld a, 32
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, idof_vBlankTile
    ld [hl], a
    ld a, 31
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    dec b
    jr nz, .cleanLoop

    ld a, [wActivePlayer]
    ; Add `a` to `wPlayerEquipped` and store in `hl`
    add a, LOW(wPlayerEquipped)
    ld l, a
    adc a, HIGH(wPlayerEquipped)
    sub a, l
    ld h, a
    ld b, [hl]

    ; Draw A button
    get_tilemap hl, _SCRN1, 3, 9
    ld a, b
    and a, $0F
    jr z, .drawB
    dec a
    ; This only works because items cap out at 4, but this UI needs a lot of
    ; changes if I ever need more so I'm not worried.
    swap a ; a * 16
    add a, a ; a * 32
    add a, a ; a * 64
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, idof_vDash
    ld [hli], a
    inc a
    ld [hli], a
    ld a, 32 - 1
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, idof_vHint + 2
    ld [hli], a

.drawB
    get_tilemap hl, _SCRN1, 3, 9
    ld a, b
    and a, $F0
    ret z
    dec a
    and a, $F0 ; mask again in case of underflow
    ; This only works because items cap out at 4, but this UI needs a lot of
    ; changes if I ever need more so I'm not worried.
    ; swap a (not needed for high byte)
    add a, a ; a * 2 (32)
    add a, a ; a * 4 (64)
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, idof_vDash
    ld [hli], a
    ld a, idof_vHint + 1
    ld [hli], a
    ld a, 32 - 1
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, idof_vHint + 3
    ld [hli], a
    ret

SECTION "Inventory Data", ROMX
InventoryMap:
    INCBIN "res/gfx/ui/inventory.tilemap"
.end
InventoryGraphics:
    INCBIN "res/gfx/ui/inventory.2bpp"
.end

Text:
.save
    DB "Save", 0
.saveAndExit
    DB "Save & Exit", 0
.close
    DB "Close", 0
.octavia
    DB "Octavia", 0
.poppy
    DB "Poppy", 0
.tiber
    DB "Tiber", 0

SECTION "Inventory Variables", WRAM0
; Which direction is the doll facing?
wPlayerDollDirection:
    DS 1

; Step and directory timer
wPlayerDollTimer:
    DS 1

; The return position when going between columns
wLastSelectedItem:
    DS 1
