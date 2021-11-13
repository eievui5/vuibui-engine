
INCLUDE "enum.inc"

    IF !DEF(PLAYERS_INC)
DEF PLAYERS_INC EQU 1

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

; AI constants
DEF OCTAVIA_FOLLOW_DISTANCE EQU 32 ; Distance at which to stop following the player.
DEF POPPY_FOLLOW_DISTANCE EQU 16
DEF TIBER_FOLLOW_DISTANCE EQU 48
DEF FOLLOW_CLOSE EQU 16
DEF FOLLOW_FAR EQU 32

DEF OCTAVIA_FIRE_DAMAGE EQU 2
DEF OCTAVIA_ICE_DAMAGE EQU 3
DEF OCTAVIA_SHOCK_DAMAGE EQU 3
DEF OCTAVIA_HEAL_AMOUNT EQU 1

DEF POPPY_ARROW_DAMAGE EQU 1

DEF TIBER_SWORD_DAMAGE EQU 2

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
        enum SWORD
        enum SWORD_SWOOSH
        enum SHIELD
    end_enum

; The state of the 3 players.
    start_enum PLAYER_STATE
        enum NORMAL
        enum HURT, ITEM_START ; Used to convert items to states
        enum ITEM0
        enum ITEM1
        enum ITEM2
        enum ITEM3
    end_enum

; Items
    start_enum ITEM,
        enum NULL_ITEM
        enum FIRE_WAND, BOW, SWORD
        enum ICE_WAND, SHIELD
        enum SHOCK_WAND
        enum HEAL_WAND
    end_enum

    DEF ITEMF_FIRE_WAND     EQU 1
    DEF ITEMF_ICE_WAND      EQU 2
    DEF ITEMF_SHOCK_WAND    EQU 4
    DEF ITEMF_HEAL_WAND     EQU 8

    DEF ITEMF_BOW           EQU 1

    DEF ITEMF_SWORD         EQU 1
    DEF ITEMF_SHIELD        EQU 2

    start_enum SPELL
        enum FIRE
        enum ICE
        enum SHOCK
        enum HEAL
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
