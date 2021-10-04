
    IF !DEF(ENGINE_INC)
DEF ENGINE_INC EQU 1

INCLUDE "enum.inc"
INCLUDE "hardware.inc"

; Screen States

; Normal Display mode
DEF SCREEN_NORMAL EQU LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON  | LCDCF_BGON
; Hide objects and switch to second tilemap for UI.
DEF SCREEN_HUD EQU    LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG9C00 | LCDCF_OBJ16 | LCDCF_OBJOFF | LCDCF_BGON
; Same as HUD, but with objects shown.
DEF SCREEN_MENU EQU   LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG9C00 | LCDCF_OBJ16 | LCDCF_OBJON  | LCDCF_BGON
; Skip a frame. Set `rLCDC` to this to skip a broken frame.
DEF SKIP_FRAME EQU LCDCF_ON

; Engine Flags

    start_enum ENGINE_STATE
        enum GAMEPLAY
        enum ROOM_TRANSITION
        enum MENU
    end_enum

    start_enum PALETTE_STATE
        enum NONE
        enum FADE_DARK ; Fade all colors to default dark shade
        enum FADE_LIGHT ; Fade all colors to default light shade
        enum RESET ; Set colors to the color buffer
        enum FADE
    end_enum

    start_enum PRINT_STATE
        enum NONE
        enum START
        enum INITIAL_CLEAN
        enum SCROLL
        enum WAIT
        enum SLIDE_OUT
    end_enum

    start_enum SYSTEM
        enum DMG
        enum CGB
        enum AGB
    end_enum

DEF STAT_ENABLE_WINDOW EQU 0
DEF STAT_DISABLE_WINDOW EQU 1

ENDC
