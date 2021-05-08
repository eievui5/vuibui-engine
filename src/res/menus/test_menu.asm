INCLUDE "include/bool.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/menu.inc"

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
    db 3
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

    xor a, a
    ldh [rLCDC], a
    ldh [rSCX], a
    ldh [rSCY], a

    ld de, TestMenuLayout
    ld hl, _SCRN1
    ld b, SCRN_Y_B - 2
    call ScreenCopy

    ld a, SCREEN_MENU
    ldh [rLCDC], a
    ldh [hLCDCBuffer], a

    ei

    ret

TestMenuRedraw:
    ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, TestMenuRedraw

    ld a, $82
    ld [_SCRN1], a
    ld [_SCRN1 + 32], a
    ld [_SCRN1 + 64], a

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
    ld hl, _SCRN1
    ld b, a
    and a, a
    jr z, .multSkip
.mult
    ld a, 32
    add_r16_a hl
    dec b
    jr nz, .mult
.multSkip

    ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, .multSkip

    ld a, $81
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
    dec a
    ret nz
    
    ld [hEngineState], a
    ld a, MENU_ACTION_VALIDATE
    ld a, SCREEN_NORMAL
    ld [hLCDCBuffer], a
    ret

TestMenuLayout:
    REPT 20 * 16
        db $82
    ENDR