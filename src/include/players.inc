
INCLUDE "include/enum.inc"

    IF !DEF(PLAYERS_INC)
DEF PLAYERS_INC SET 1

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
DEF KNOCK_FRAMES EQU 15
DEF INVINCIBLE_FRAMES EQU 60

; Items
DEF ITEM_FIRE_WAND EQU 1

; AI constants
DEF OCTAVIA_FOLLOW_DISTANCE EQU 32 ; Distance at which to stop following the player.
DEF POPPY_FOLLOW_DISTANCE EQU 16
DEF TIBER_FOLLOW_DISTANCE EQU 48

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

; Offset for player metasprites
    start_enum FRAMEOFF, 0, 4
        enum NORMAL
        enum STEP 
        enum SWING
        enum GRAB
    end_enum

; The state of the 3 players.
    start_enum PLAYER_STATE
        enum NORMAL
        enum HURT
        enum FIRE_WAND
    end_enum

; Which set of entity logic are the Allies using?
    start_enum ALLY_MODE
        enum FOLLOW
    end_enum

; Player IDs
    start_enum PLAYER
        enum OCTAVIA
        enum POPPY
        enum TIBER
    end_enum

ENDC
