INCLUDE "include/bool.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/menu.inc"
INCLUDE "include/text.inc"

    start_enum M, $80
        enum BKG
        enum POINTER
        enum S
        enum t
        enum a
        enum r
        enum O
        enum p
        enum i
        enum o
        enum n
        enum s
    end_enum

DEF POINTER_ANIM_MAX EQU 2
DEF POINTER_ANIM_POINT EQU 16

SECTION "Menu Test", ROMX

TestMenuHeader::
    db BANK("Menu Test")
    dw TestMenuInit
    ; Used Buttons
    db PADF_A | PADF_B | PADF_UP | PADF_DOWN
    ; Auto-repeat
    db FALSE
    ; Button functions
    dw HandleAPress, null, null, null, null, null, null, null
    db 0 ; Last selected item
    ; Allow wrapping
    db TRUE
    ; Default selected item
    db 0
    ; Number of items in the menu
    db 2
    ; Redraw
    dw TestMenuRedraw
    ; Private Items Pointer
    dw 0
    ; Close Function
    dw null

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
    ld a, $FF
    get_tile hl, M_POINTER
    ld bc, sizeof_TILE
    call memset


    get_tile de, M_S

    ld hl, TestMenuString
    call LoadCharacters

    ld hl, _SCRN1
    ld bc, M_BKG << 8 | SCRN_Y_B
    call ScreenSet

    get_tilemap hl, _SCRN1, 0, 10
    ld de, TestMenuStartRow
    ld b, 1
    call ScreenCopy
    
    get_tilemap hl, _SCRN1, 0, 12
    ld de, TestMenuOptionsRow
    ld b, 1
    call ScreenCopy

    ; Load palettes
    ld hl, PalGrey
    ld de, wBCPD
    ld c, sizeof_PALETTE
    call memcopy_small
    ld a, PALETTE_STATE_RESET
    ld [wPaletteState], a
    call UpdatePalettes

    ld a, SCREEN_MENU
    ldh [rLCDC], a
    ldh [hLCDCBuffer], a

    ei

    ret

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
    rst memcopy_small

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
    xor a, a
    ld [wMenuAction], a

    ; Grab the menu pointer off the stack
    ld hl, sp + 2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; RedrawFunc + 1
    inc hl

    ld a, [hl]
    and a, a
    ret nz

    ld a, MENU_ACTION_VALIDATE
    ld [wMenuAction], a

    jp InitializeGameplay

TestMenuString:
    db "StarOpions", 0

TestMenuStartRow:
    db M_BKG, M_BKG, M_BKG, M_BKG, M_BKG, M_S, M_t, M_a, M_r, M_t, M_BKG, M_BKG, M_BKG, M_BKG, M_BKG, M_BKG, M_BKG, M_BKG, M_BKG, M_BKG

TestMenuOptionsRow:
    db M_BKG, M_BKG, M_BKG, M_BKG, M_BKG, M_O, M_p, M_t, M_i, M_o, M_n, M_s, M_BKG, M_BKG, M_BKG, M_BKG, M_BKG, M_BKG, M_BKG, M_BKG

TestMenuSprites:
.start
    db $B * 8, $4 * 8, M_POINTER, 0
.options
    db $D * 8, $4 * 8, M_POINTER, 0

SECTION "Test Menu Vars", WRAM0
wPointerDir:
    ds 1
wPointerOffset:
    ds 1
wPointerYPos:
    ds 1