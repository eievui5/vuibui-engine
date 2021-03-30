

    IF !DEF(ENUM_INC)
DEF ENUM_INC SET 1

; Start a new enumeration.
; @ start_enum Name, [start], [step]
MACRO start_enum 

; Start an enumeration
    IF _NARG < 1
        FAIL "Expected at least 1 arg"
    ENDC
    IF DEF(ENUM_NAME)
        FAIL "Close enums with `end_enum`"
    ENDC

    DEF ENUM_NAME EQUS "\1"

; Handle start position
    IF _NARG > 1
        RSSET \2
    ELSE
        RSRESET
    ENDC

; Handle step amount
    IF _NARG == 3
        DEF ENUM_STEP EQU \3
    ELSE
        DEF ENUM_STEP EQU 1
    ENDC
ENDM

; Add new values to the enumeration, one higher than the last. 
; Will result in the constant "Name_Value"
; @ enum Value, [Value]...
MACRO enum
    IF !DEF(ENUM_NAME)
        FAIL "`enum` missing opening `start_enum`!"
    ENDC
    FOR i, _NARG
        DEF ENUM_FIELD_NAME EQUS "{ENUM_NAME}_\1" 
        IF i != 0
            RSSET _RS - ENUM_STEP
        ENDC
ENUM_FIELD_NAME RB ENUM_STEP
        PURGE ENUM_FIELD_NAME
        SHIFT
    ENDR

ENDM

; End an enumeration and clean up
MACRO end_enum
    IF !DEF(ENUM_NAME)
        FAIL "`end_enum` missing opening `start_enum`!"
    ENDC
    PURGE ENUM_NAME
    PURGE ENUM_STEP
    RSRESET
ENDM

    ENDC