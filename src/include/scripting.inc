
SCRIPT_END EQU 0
SCRIPT_NULL EQU 1
SCRIPT_TEXT EQU 2

; Returns to normal processing
MACRO end_script
    db SCRIPT_END
ENDM

; Pauses the script to open a text box
; @ display_text TextPointer
MACRO display_text
    db SCRIPT_TEXT
    db bank(\1)
    db high(\1)
    db low(\1)
ENDM
