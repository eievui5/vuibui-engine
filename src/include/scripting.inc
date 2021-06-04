
    IF !DEF(SCRIPTING_INC)
DEF SCRIPTING_INC EQU 1
    
INCLUDE "include/enum.inc"

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
    end_enum

; Returns to normal processing
MACRO end_script
    db SCRIPT_END
ENDM

; Used to break up simu-ops, such as movement.
MACRO pass
    db SCRIPT_NULL
ENDM

; Pauses the script to open a text box
; @ display_text TextPointer
MACRO display_text
    IF _NARG != 1
        FAIL "Expected 1 arg"
    ENDC
    db SCRIPT_TEXT
    db bank(\1)
    db high(\1)
    db low(\1)
ENDM

; Sets the given player's position and direction. Will not scroll the camera (yet) and thus has weird effects.
; @ player_setpos OCTAVIA, 0, 0, DIRECTION, DIR_DOWN
MACRO setpos_player
    IF _NARG != 4
        FAIL "Expected 4 args"
    ENDC
    db SCRIPT_SETPOS_PLAYER
    db \1 ; Player
    db \2, \3 ; Position
    db \4 ; Direction
ENDM

    ENDC

; Branches to `.label0` if `pointer` is 0, and `.label1` otherwise
; @ branch pointer, value, .label0, .label1
; @ pointer: Pointer to the value to compare
; @ value: Value to compare to pointer
; @ .label0: Location to jump to if the check succeeds.
; @ .label1: Location to jump to if the check fails.
MACRO branch
    IF _NARG != 4
        FAIL "Expected 4 args"
    ENDC
    db SCRIPT_BRANCH
    dw \1, 
    db \2
    dw \3, \4
ENDM

; Sets the reffered `pointer` to `value`
; @ set_pointer Pointer, Value
MACRO set_pointer
    IF _NARG != 2
        FAIL "Expected 2 args"
    ENDC
    db SCRIPT_SET_POINTER
    dw \1
    db \2
ENDM

; Calls a block of code.
; @ call_function Pointer
MACRO call_function
    IF _NARG != 1
        FAIL "Expected 1 arg"
    ENDC
    db SCRIPT_FUNCTION
    dw \1
ENDM

; Compares two pointers
; @ compare .pointer0, .pointer1, .label0, .label1
; @ .pointer0: Pointer to the value to compare
; @ .pointer1:
; @ .label0: Location to jump to if the check succeeds.
; @ .label1: Location to jump to if the check fails.
MACRO compare
    IF _NARG != 4
        FAIL "Expected 4 args"
    ENDC
    db SCRIPT_COMPARE
    dw \1, \2, \3, \4
ENDM

; Update text box gradient.
; @ text_color Gradient
MACRO text_color
    IF _NARG != 1
        FAIL "Expected 1 arg"
    ENDC
    db SCRIPT_SET_TEXT_GRADIENT
    db BANK(\1)
    dw \1
ENDM

; Pause the game
MACRO pause
    db SCRIPT_PAUSE
ENDM

; Unpause the game
MACRO unpause
    db SCRIPT_UNPAUSE
ENDM

; ################# Pseudo-Scripts

; Branches to `.label0` if the first option was chosen, and `.label1` otherwise
; @ question_branch .label0, .label1
MACRO question_branch
    branch wTextAnswer, 0, \1, \2
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