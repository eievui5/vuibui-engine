
    IF !DEF(GRAPHICS_INC)
DEF GRAPHICS_INC EQU 1

INCLUDE "hardware.inc"
INCLUDE "vdef.inc"

; Metasprite end byte
DEF METASPRITE_END EQU 128

DEF _VRAM_OBJ EQU $8000
DEF _VRAM_SHARED EQU $8800
DEF _VRAM_BG EQU $9000

DEF sizeof_COLOR EQU 3
DEF sizeof_PALETTE EQU sizeof_COLOR * 4
DEF sizeof_TILE EQU 16
DEF sizeof_1BPP EQU 8

DEF DEFAULT_BLUE EQU 0
DEF DEFAULT_GREEN EQU 1
DEF DEFAULT_RED EQU 2
DEF DEFAULT_INV EQU 3

DEF HUD_MAIN_PAL EQU 7

; get_tilemap r16, _SCRN0, X, Y
MACRO get_tilemap
    IF _NARG != 4
        FAIL "Expected 4 args!"
    ENDC
    ld \1, \2 + \3 + (32 * \4)
ENDM

; get_tile r16, ID
MACRO get_tile
    IF _NARG != 2
        FAIL "Expected 2 args!"
    ENDC
    IF \2 < $80
        ld \1, _VRAM_BG + (\2 * sizeof_TILE)
    ELSE
        ld \1, _VRAM_SHARED + ((\2 - $80) * sizeof_TILE)
    ENDC
ENDM

; get_object r16, ID
MACRO get_object
    IF _NARG != 2
        FAIL "Expected 2 args!"
    ENDC
    IF \2 < $80
        ld \1, _VRAM_OBJ + (\2 * sizeof_TILE)
    ELSE
        ld \1, _VRAM_SHARED + (\2 * sizeof_TILE)
    ENDC
ENDM

MACRO rgb
    ASSERT _NARG == 3, "Expected 3 args!"
    ASSERT !(\1 > 31 || \2 > 31 || \3 > 31), "Colors must be between 0 and 31"
    DB (\1) << 3, (\2) << 3, (\3) << 3
ENDM

MACRO pal
    IF _NARG != 12
        FAIL "Expected 12 args!"
    ENDC
    REPT 4
        rgb \1, \2, \3
        SHIFT 3
    ENDR
ENDM

MACRO pal_blank
    pal 31, 31, 31, \
        20, 20, 20, \
        10, 10, 10, \
        0,  0,  0
ENDM

; Tile constants

    dtile_section $8000
    ; Octavia
    dtile vOctaviaDown, 4
    dtile vOctaviaUp, 4
    dtile vOctaviaRight, 4
    dtile vOctaviaRightStep, 4
    dtile vOctaviaActDown, 2
    dtile vOctaviaActUp, 2
    dtile vOctaviaActRight, 2
    ; Poppy
    dtile vPoppyDown, 4
    dtile vPoppyUp, 4
    dtile vPoppyRight, 4
    dtile vPoppyRightStep, 4
    dtile vPoppyActDown, 2
    dtile vPoppyActUp, 2
    dtile vPoppyActRight, 2
    ; Tiber
    dtile vTiberDown, 4
    dtile vTiberUp, 4
    dtile vTiberRight, 4
    dtile vTiberRightStep, 4
    dtile vTiberActDown, 2
    dtile vTiberActUp, 2
    dtile vTiberActRight, 2
    ; Player Items
    dtile vSpell, 2
    dtile vArrowDown, 2
    dtile vArrowRight, 4
    dtile vSwordUp, 2
    dtile vSwordRight, 4
    dtile vSwordSwoosh, 2
    dtile vShield, 4
    dtile vShieldSide, 2
    ; Other common sprites
    dtile vSparkle, 4
    dtile vHeartContainer, 4

DEF vTextTiles EQU $9500
DEF TILE_TEXT_START EQU $50

    ENDC