    IF !DEF(ENTITY_SCRIPT_INC)
DEF ENITITY_SCRIPT_INC EQU 1

INCLUDE "enum.inc"

; Reduce this reserve fields for scripting.
DEF MAX_FIELDS EQU 14

    start_enum ENTITY_SCRIPT
        enum YIELD
        enum JUMP
        enum SETA
        enum SETF
        enum SETM
        enum KILL
        enum ADDA
        enum ADDF
        enum MOVE
        enum GETM
        enum CHASE_PLAYER
        enum ANIMATE
        enum INLINE
        enum FOR
        enum RAND
        enum ATTACK_PLAYER
        enum IF_NEG
        enum DEATH_PARTICLES
        enum TARGET_DIRECTION
    end_enum

; Scripting functions:

; Return control back to the entity's code; continue on the next frame.
MACRO yield
    DB ENTITY_SCRIPT_YIELD
ENDM

; Jump the script to a label
MACRO jump
    ASSERT _NARG == 1, "Expected 1 argument!"
    DB ENTITY_SCRIPT_JUMP
    ; BE jumps save a single byte :3
    DB HIGH(\1), LOW(\1)
ENDM

; Set the nth member of the entity's struct
; @ seta index, value
MACRO seta
    ASSERT _NARG == 2, "Expected 2 arguments!"
    ASSERT \1 <= 16, "Index must be <= 16"
    DB ENTITY_SCRIPT_SETA, \1, \2
ENDM

; Set the nth member of the entity's fields
; @ setf index, value
MACRO setf
    ASSERT _NARG == 2, "Expected 2 arguments!"
    ASSERT \1 <= MAX_FIELDS, "Index is invalid; must be <= {MAX_FIELDS}"
    DB ENTITY_SCRIPT_SETF, \1, \2
ENDM

; Set a location in memory.
; @ setm pointer, value
MACRO setm
    ASSERT _NARG == 2, "Expected 2 arguments!"
    DB ENTITY_SCRIPT_SETM
    DW \1
    DB \2
ENDM

; Removes the entity from the entity array.
MACRO kill
    DB ENTITY_SCRIPT_KILL
ENDM

MACRO adda
    ASSERT _NARG == 2, "Expected 2 arguments!"
    ASSERT \1 <= 16, "Index must be <= 16"
    DB ENTITY_SCRIPT_ADDA, \1, \2
ENDM

MACRO addf
    ASSERT _NARG == 2, "Expected 2 arguments!"
    ASSERT \1 <= MAX_FIELDS, "Index is invalid; must be <= {MAX_FIELDS}"
    DB ENTITY_SCRIPT_ADDF, \1, \2
ENDM

; Moves based on the current velocity
; @ move
MACRO move
    DB ENTITY_SCRIPT_MOVE
ENDM

; Grabs a value from memory and stores it in a field
; @ getm pointer, field
MACRO getm
    ASSERT _NARG == 2, "Expected 2 arguments!"
    DB ENTITY_SCRIPT_GETM
    DW \1
    DB \2
ENDM

; Chases the player pointed to by a given field
MACRO chase_player
    DB ENTITY_SCRIPT_CHASE_PLAYER
ENDM

MACRO animate
    ASSERT _NARG == 4, "Expected 4 arguments!"
    DB ENTITY_SCRIPT_ANIMATE, \1, \2, \3, \4
ENDM


MACRO inline
    ASSERT _NARG == 1, "Expected the end of the inline as an argument"
    DB ENTITY_SCRIPT_INLINE, \1 - @
ENDM

; Decrements a field and jumps to the next `endfor` if it is zero. Creates a
; local label for `endfor` to create a loop.
; @ forf field
MACRO forf
    ASSERT _NARG == 1, "Expected 1 or 2 arguments!"
:   db ENTITY_SCRIPT_FOR, (\1 + 2)
    DW :+
ENDM

; Decrements an array field and jumps to the next `endfor` if it is zero.
; Creates a local label for `endfor` to create a loop.
; @ fora field
MACRO fora
    ASSERT _NARG == 1, "Expected 1 arguments!"
:   db ENTITY_SCRIPT_FOR, 0 - (\1)
    DW :+
ENDM

; Creates an exit local label and a jump to the previous local label. Used to
; close a for loop.
; @ endfor
MACRO endfor
    jump :-
:
ENDM

; Generates an 8-bit random integer, `and`s it with the provided mask, and then
; stores it in a given field.
; @ rand field, [mask]
MACRO randf
    IF _NARG == 1
        DB ENTITY_SCRIPT_RAND, $FF, \1 + 2
    ELIF _NARG == 2
        DB ENTITY_SCRIPT_RAND, \2, \1 + 2
    ELSE
        FAIL "Expected 1 or 2 arguments!"
    ENDC
ENDM

; Generates an 8-bit random integer, `and`s it with the provided mask, and then
; stores it in a given field.
; @ rand field, [mask]
MACRO randa
    IF _NARG == 1
        DB ENTITY_SCRIPT_RAND, $FF, 0 - \1
    ELIF _NARG == 2
        DB ENTITY_SCRIPT_RAND, \2, 0 - \1
    ELSE
        FAIL "Expected 1 or 2 arguments!"
    ENDC
ENDM

; @ attack_player damage
MACRO attack_player
    ASSERT _NARG == 1, "Expected 1 arguments!"
    DB ENTITY_SCRIPT_ATTACK_PLAYER, \1
ENDM

; @ attackplayerf field
MACRO attack_playerf
    ASSERT _NARG == 1, "Expected 1 arguments!"
    DB ENTITY_SCRIPT_ATTACK_PLAYER, 0 - (\1 + 2)
ENDM

MACRO if_negf
    ASSERT _NARG == 1, "Expected 1 arguments!"
    DB ENTITY_SCRIPT_IF_NEG, (\1 + 2)
    DW :+
ENDM

MACRO if_nega
    ASSERT _NARG == 1, "Expected 1 arguments!"
    DB ENTITY_SCRIPT_IF_NEG, 0 - (\1)
    DW :+
ENDM

MACRO endif
:
ENDM

; Kills the entity and spawns death particles
MACRO death_particles
    DB ENTITY_SCRIPT_DEATH_PARTICLES
ENDM

MACRO target_dir
    DB ENTITY_SCRIPT_TARGET_DIRECTION
ENDM

; Define fields:

MACRO define_fields
    IF DEF(FIELD_INDEX)
        REDEF FIELD_INDEX SET 0
    ELSE
        DEF FIELD_INDEX SET 0
    ENDC
ENDM

MACRO field
    ASSERT DEF(FIELD_INDEX), "Begin field definitions with `define_fields`"
    FOR i, _NARG
        DEF \1 EQU FIELD_INDEX
        SHIFT 1
    ENDR
    REDEF FIELD_INDEX SET FIELD_INDEX + 1
ENDM

    ENDC