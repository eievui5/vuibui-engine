
    IF !DEF(SCRIPTING_INC)
SCRIPTING_INC SET 1
    
INCLUDE "include/enum.inc"

    start_enum SCRIPT 
        enum END
        enum NULL
        enum TEXT
        enum SETPOS_PLAYER
        enum BRANCH
        enum SET_POINTER
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
        "Expected 1 arg"
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
        "Expected 4 args"
    ENDC
    db SCRIPT_SETPOS_PLAYER
    db \1 ; Player
    db \2, \3 ; Position
    db \4 ; Direction
ENDM

    ENDC

; Branches to `.label0` if `pointer` is 0, and `.label1` otherwise
; @ branch pointer, .label0, .label1
MACRO branch
    IF _NARG != 3
        "Expected 3 args"
    ENDC
    db SCRIPT_BRANCH
    dw \1, \2, \3
ENDM

; Branches to `.label0` if `wTextAnswer` is 0, and `.label1` otherwise
; @ question_branch .label0, .label1
MACRO question_branch
    branch wTextAnswer, \1, \2
ENDM

; Sets the reffered `pointer` to `value`
; @ set_pointer Pointer, Value
MACRO set_pointer
    IF _NARG != 2
        "Expected 2 args"
    ENDC
    db SCRIPT_SET_POINTER
    dw \1
    db \2
ENDM