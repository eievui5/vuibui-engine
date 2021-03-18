
INCLUDE "include/enum.inc"

    IF !DEF(PLAYERS_INC)
PLAYERS_INC SET 1

; Used to find a player's data at a given offset, storing it in hl. 
; @ bc: PLAYER enum * sizeof_Entity
; @ 3 bytes
; @ 5 cycles
MACRO find_player
    IF _NARG > 0
        ld hl, wPlayerArray + \1
    ELSE
        ld hl, wPlayerArray
    ENDC 
    add hl, bc
ENDM

; Timer constants
KNOCK_FRAMES EQU 15
INVINCIBLE_FRAMES EQU 60

; Items
ITEM_FIRE_WAND EQU 1

; Animation Frames
    start_enum PLAYER_FRAME
        ; NORMAL
        enum DOWN
        enum UP
        enum RIGHT
        enum LEFT
        ; STEP
        enum DOWN_STEP
        enum UP_STEP
        enum RIGHT_STEP
        enum LEFT_STEP
        ; SWING
        enum DOWN_SWING
        enum UP_SWING
        enum RIGHT_SWING
        enum LEFT_SWING
        ; GRAB
        enum DOWN_GRAB
        enum UP_GRAB
        enum RIGHT_GRAB
        enum LEFT_GRAB
    end_enum
    start_enum FRAMEOFF, 0, 4
        enum NORMAL
        enum STEP 
        enum SWING
        enum GRAB
    end_enum

    start_enum PLAYER_STATE
        enum NORMAL
        enum HURT
        enum FIRE_WAND
    end_enum

    start_enum PLAYER
        enum OCTAVIA
        enum POPPY
        enum TIBER
    end_enum

ENDC
