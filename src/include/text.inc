
    IF !DEF(TEXT_INC)
DEF TEXT_INC SET 1

INCLUDE "include/enum.inc"

    start_enum SPCHAR
        enum QUESTION
    end_enum

MACRO say
    IF _NARG != 1
        FAIL "Expected one string as input!"
    ENDC
    ; This makes sure that the line is under 15 Characters, 16 if a newline is present
    IF STRLEN(\1) > 15
        IF STRSUB(\1, 16, 1) != "\n"
            FAIL "Line is longer than 15 characters!"
        ENDC
    ENDC
    db \1
ENDM

; Types an "@" and creates an `.end` label
MACRO end_text
    db "@"
ENDM

MACRO ask
    IF _NARG != 1
        FAIL "Expected one string as input!"
    ENDC
    ; This makes sure that the line is under 13 Characters, 14 if a newline is present
    IF STRLEN(\1) > 13
        IF STRSUB(\1, 14, 1) != "\n"
            FAIL "Question is longer than 13 characters!"
        ENDC
    ENDC
    db "  ", \1
ENDM

MACRO end_ask
    db SPCHAR_QUESTION
ENDM

DEF vTextTiles EQU $8000 + $1500

    start_enum TEXT
        enum HIDDEN     ; No text
        enum START      ; Initiallize text
        enum CLEARING   ; Clear the text window
        enum CLEANING   ; 2nd step
        enum DRAWING    ; Draw text
        enum WAITING    ; Wait for input.
        enum ASK        ; Allow the player to select a line.
    end_enum

ENDC
