    IF !DEF(SCRIPTING_INC)
DEF SCRIPTING_INC EQU 1

INCLUDE "enum.inc"

    start_enum SCRIPT
        enum END
        enum NULL
        enum TEXT
        enum SETPOS_PLAYER
        enum BRANCH
        enum SET_POINTER
        enum FUNCTION
        enum COMPARE
        enum SET_TEXT_GRADIENT
        enum PAUSE
        enum UNPAUSE
        enum FADE
        enum WAIT_FADE
        enum JUMP
        enum ADD_POINTER
        enum BRANCH_AND
    end_enum

; Returns to normal processing
MACRO end_script
    DB SCRIPT_END
ENDM

MACRO pass
    DB SCRIPT_NULL
ENDM

; Pauses the script to open a text box
; @ display_text TextPointer
MACRO display_text
    ASSERT _NARG == 1, "Expected 1 arg"
    DB SCRIPT_TEXT
    DB bank(\1)
    DW \1
ENDM

; Sets the given player's position and direction. Will not scroll the camera (yet) and thus has weird effects.
; @ player_setpos OCTAVIA, 0, 0, DIRECTION, DIR_DOWN
MACRO setpos_player
    IF _NARG != 4
        FAIL "Expected 4 args"
    ENDC
    DB SCRIPT_SETPOS_PLAYER
    DB \1 ; Player
    DB \2, \3 ; Position
    DB \4 ; Direction
ENDM

; Branches to `.label` if `pointer` equals `value`
; @ branch pointer, value, .label
; @ pointer: Pointer to the value to compare
; @ value: Value to compare to pointer
; @ .label: Location to jump to if the check succeeds.
MACRO branch
    ASSERT _NARG == 3, "Expected 3 args"
    DB SCRIPT_BRANCH
    DW \1,
    DB \2
    DW \3
ENDM

; Sets the reffered `pointer` to `value`
; @ set_pointer Pointer, Value
MACRO set_pointer
    ASSERT _NARG == 2, "Expected 2 args"
    DB SCRIPT_SET_POINTER
    DW \1
    DB \2
ENDM

; Calls a block of code.
; @ call_function Pointer
MACRO call_function
    ASSERT _NARG == 1, "Expected 1 arg"
    DB SCRIPT_FUNCTION
    DW \1
ENDM

; Jump if two pointers are equal
; @ compare .pointer0, .pointer1, .label
; @ .pointer0: Pointer to the value to compare
; @ .pointer1:
; @ .label0: Location to jump to if the check succeeds.
MACRO jump_if
    ASSERT _NARG == 3, "Expected 3 args"
    DB SCRIPT_COMPARE
    DW \1, \2, \3
ENDM

; Update text box gradient.
; @ text_color Gradient
MACRO text_color
    ASSERT _NARG == 1, "Expected 1 arg"
    DB SCRIPT_SET_TEXT_GRADIENT
    DB BANK(\1)
    DW \1
ENDM

; Pause the game
MACRO pause
    DB SCRIPT_PAUSE
ENDM

; Unpause the game
MACRO unpause
    DB SCRIPT_UNPAUSE
ENDM

; Fade palettes.
MACRO fade
    ASSERT _NARG == 1, "Expected 1 arg"
    ASSERT \1 <= PALETTE_STATE_FADE
    DB SCRIPT_FADE, \1
ENDM

; Lock the script until palettes are done fading.
MACRO wait_fade
    DB SCRIPT_WAIT_FADE
ENDM

; Move the script pointer, or in other words, jump!
MACRO jump
    DB SCRIPT_JUMP
    ASSERT BANK(@) == BANK(\1), "`jump` can only jump to scripts in the same bank!"
    DW \1
ENDM

; Adds `value` to `pointer`.
; @ add_pointer Pointer, Value
MACRO add_pointer
    ASSERT _NARG == 2, "Expected 2 args"
    DB SCRIPT_ADD_POINTER
    DW \1
    DB \2
ENDM

; ################# Pseudo-Scripts

; Branches to `.label` if the first option was chosen
; @ question_branch .label0
MACRO question_branch
    branch wTextAnswer, 0, \1
ENDM

MACRO octavia_text
    text_color GradientBlue
    display_text \1
ENDM

MACRO poppy_text
    text_color GradientGreen
    display_text \1
ENDM

MACRO tiber_text
    text_color GradientRed
    display_text \1
ENDM

; Subtracts `value` from `pointer`.
; @ sub_pointer Pointer, Value
MACRO sub_pointer
    ASSERT _NARG == 2, "Expected 2 args"
    DB SCRIPT_ADD_POINTER
    DW \1
    DB -(\2)
ENDM

    ENDC
