
    IF !DEF(SCRIPTING_INC)
SCRIPTING_INC SET 1
    
INCLUDE "include/enum.inc"

    start_enum SCRIPT 
        enum END
        enum NULL
        enum TEXT
        enum SETPOS_PLAYER
        enum QUESTION_BRANCH
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

; Branches to label 0 if the first response was chosen, and label 1 otherwise
; @ question_branch .label0, .label1
MACRO question_branch
    IF _NARG != 2
        "Expected 2 args"
    ENDC
    db SCRIPT_QUESTION_BRANCH
    dw \1, \2
ENDM
