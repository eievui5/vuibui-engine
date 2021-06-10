    IF !DEF(ENTITY_SCRIPT_INC)
DEF ENITITY_SCRIPT_INC EQU 1

INCLUDE "include/enum.inc"

; Reduce this reserve fields for scripting.
DEF MAX_FIELDS EQU 14

    start_enum ENTITY_SCRIPT
        enum YIELD
        enum JUMP
        enum SETA
        enum SETF
        enum SETM
    end_enum

; Scripting functions:

; Return control back to the entity's code; continue on the next frame.
MACRO yield
    db ENTITY_SCRIPT_YIELD
ENDM

; Jump the script to a label
MACRO jump
    ASSERT _NARG == 1, "Expected 1 argument!"
    db ENTITY_SCRIPT_JUMP
    ; BE jumps save a single byte :3
    db HIGH(\1), LOW(\1)
ENDM

; Set the nth member of the entity's struct
; @ seta index, value
MACRO seta
    ASSERT _NARG == 2, "Expected 2 arguments!"
    ASSERT \1 <= 16, "Index must be <= 16"
    db ENTITY_SCRIPT_SETA, \1, \2
ENDM

; Set the nth member of the entity's fields
; @ setf index, value
MACRO setf
    ASSERT _NARG == 2, "Expected 2 arguments!"
    ASSERT \1 <= MAX_FIELDS, "Index is invalid; must be <= {MAX_FIELDS}"
    db ENTITY_SCRIPT_SETF, \1, \2
ENDM

; Set a location in memory.
; @ setm pointer, value
MACRO setm
    ASSERT _NARG == 2, "Expected 2 arguments!"
    db ENTITY_SCRIPT_SETM
    dw \1
    db \2
ENDM

; Define fields:

MACRO start_fields
    IF DEF(FIELD_INDEX)
        REDEF FIELD_INDEX SET 0
    ELSE
        DEF FIELD_INDEX SET 0
    ENDC
ENDM

MACRO field
    ASSERT DEF(FIELD_INDEX), "Begin field definitions with `define_fields`"
    ASSERT _NARG == 1, "Expected 1 argument!"
    DEF {\1} EQU FIELD_INDEX
    REDEF FIELD_INDEX SET FIELD_INDEX + 1
ENDM

    ENDC