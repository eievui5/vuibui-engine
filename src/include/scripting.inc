
SCRIPT_END EQU 0
SCRIPT_NULL EQU 1
SCRIPT_TEXT EQU 2
SCRIPT_SETPOS_PLAYER EQU 3

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
; @ player_setpos OCTAVIA, 0, 0, DIRECTION, DIR_OFFSET_DOWN
MACRO setpos_player
    IF _NARG != 4
        "Expected at least 4 args"
    ENDC
    db SCRIPT_SETPOS_PLAYER
    db \1 ; Player
    db \2, \3 ; Position
    db \4 ; Direction
ENDM
