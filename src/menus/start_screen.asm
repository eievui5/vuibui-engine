INCLUDE "engine.inc"
INCLUDE "graphics.inc"
INCLUDE "hardware.inc"
INCLUDE "menu.inc"
INCLUDE "stdopt.inc"
INCLUDE "text.inc"
INCLUDE "vdef.inc"

SECTION UNION "VRAM", VRAM[$8800]
    dtile Blank
    dtile Pointer
    dtile StartStr, STRLEN("Start") + 1
    dtile OptionsStr, STRLEN("Options") + 1

DEF POINTER_ANIM_MAX EQU 2
DEF POINTER_ANIM_POINT EQU 16

SECTION "Menu Test", ROMX

TestMenuHeader::
    DB BANK("Menu Test")
    DW TestMenuInit
    ; Used Buttons
    DB PADF_A | PADF_UP | PADF_DOWN
    ; Auto-repeat
    DB 0
    ; Button functions
    DW HandleAPress, null, null, null, null, null, null, null
    DB 0 ; Last selected item
    ; Allow wrapping
    DB 1
    ; Default selected item
    DB 0
    ; Number of items in the menu
    DB 2
    ; Redraw
    DW TestMenuRedraw
    ; Private Items Pointer
    DW 0
    ; Close Function
    DW InitializeGameplay ; Initiallize gameplay when this menu closes

TestMenuInit:
; Wait for VRAM access
    di
.waitVBlank
    ldh a, [rLY]
    cp a, SCRN_Y
    jr nc, .waitVBlank

; Reset graphics
    xor a, a
    ldh [rLCDC], a
    ldh [rSCX], a
    ldh [rSCY], a

; Initiallize variables
    ld [wPointerDir], a
    ld [wPointerOffset], a
    ld a, $B * 8
    ld [wPointerYPos], a

; Load tiles
    ld a, BANK(obpp_Pointer)
    ld hl, obpp_Pointer
    ld de, vPointer
    ld c, 8
    call Unback1bppBanked

    ld hl, _SCRN1
    lb bc, idof_Blank, SCRN_Y_B
    call ScreenSet

    ld a, idof_StartStr
    ldh [hDrawStringTileBase], a
    ld bc, MenuString.start
    ld de, vStartStr + 1
    get_tilemap hl, _SCRN1, 5, 10
    call DrawString

    ld a, idof_OptionsStr
    ldh [hDrawStringTileBase], a
    ld bc, MenuString.options
    ld de, vOptionsStr + 1
    get_tilemap hl, _SCRN1, 5, 12
    call DrawString

    ; Load palettes
    ldh a, [hSystem]
    and a, a
    jr z, .cgbSkip

        ld hl, PalGrey
        ld de, wBCPD
        lb bc, BANK(PalGrey), sizeof_PALETTE
        call MemCopyFar

        ld a, PALETTE_STATE_RESET
        call UpdatePalettes
    .cgbSkip

    ld a, SCREEN_MENU
    ldh [rLCDC], a
    ldh [hLCDCBuffer], a

    reti

TestMenuRedraw:
    ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, TestMenuRedraw

    ; Grab the menu pointer off the stack
    ld hl, sp + 2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; RedrawFunc + 1
    dec hl ; RedrawFunc
    dec hl ; Size
    dec hl ; SelectedItem
    ld a, [hl]

    ; Push sprites to OAM
    ld b, a
    ld hl, TestMenuSprites
    and a, a
    jr z, .multSkip
    .mult
        inc hl
        inc hl
        inc hl
        inc hl
        dec b
        jr nz, .mult
    .multSkip
    ld de, wShadowOAM
    ld c, 4
    rst MemCopySmall

    ld hl, wShadowOAM
    ld a, [wPointerYPos]
    cp a, [hl]
    jr z, :++
    jr nc, :+
    add a, 4
    jr :++
:   sub a, 4

:   ld [hl], a
    ld [wPointerYPos], a

:   ld a, [wPointerDir]
    and a, a
    ld a, [wPointerOffset]
    jr z, :+

    inc a
    cp a, (POINTER_ANIM_MAX + 1) * POINTER_ANIM_POINT
    jr nz, :++
    xor a, a
    ld [wPointerDir], a
    ld a, POINTER_ANIM_MAX * POINTER_ANIM_POINT
    jr :++

:   dec a
    cp a, -(POINTER_ANIM_MAX + 1) * POINTER_ANIM_POINT
    jr nz, :+
    ld a, 1
    ld [wPointerDir], a
    ld a, -POINTER_ANIM_MAX * POINTER_ANIM_POINT

:   ld [wPointerOffset], a
    ld hl, wShadowOAM + 1

    ; Divide point out
    ASSERT POINTER_ANIM_POINT == 16
        sra a
        sra a
        sra a
        sra a

    add a, [hl]
    ld [hl], a

    ret

HandleAPress:
    ; Grab the menu pointer off the stack
    ld hl, sp + 2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; RedrawFunc + 1
    inc hl

    ld a, [hl]
    and a, a
    ret z

    xor a, a ; Clear validate action if not on start
    ld [wMenuAction], a
    ret

MenuString:
.start
    DB "Start!", 0
.options
    DB "Options", 0

TestMenuSprites:
.start
    DB $B * 8, $4 * 8, idof_Pointer, 0
.options
    DB $D * 8, $4 * 8, idof_Pointer, 0

SECTION "Test Menu Vars", WRAM0
wPointerDir:
    DS 1
wPointerOffset:
    DS 1
wPointerYPos:
    DS 1