
    IF !DEF(ENGINE_INC)
ENGINE_INC SET 1

INCLUDE "enum.inc"
INCLUDE "hardware.inc"

; Screen States

; All features enabled
DEF SCREEN_NORMAL EQU LCDCF_ON | LCDCF_OBJON | LCDCF_BGON | LCDCF_WINON | LCDCF_WIN9C00 | LCDCF_OBJ16
; Objects hidden
DEF SCREEN_WINDOW EQU LCDCF_ON | LCDCF_BGON | LCDCF_WINON | LCDCF_WIN9C00

; Engine Flags

    start_enum ENGINE_STATE
        enum NORMAL
        enum SCRIPT
        enum ROOM_TRANSITION
        enum ROOM_SWAP
    end_enum

    start_enum PALETTE_STATE
        enum NONE
        enum FADE_DARK ; Fade all colors to default dark shade
        enum FADE_LIGHT ; Fade all colors to default light shade
        enum RESET ; Set colors to the color buffer
    end_enum

DEF STAT_ENABLE_WINDOW EQU 0
DEF STAT_DISABLE_WINDOW EQU 1

ENDC
