INCLUDE "include/entity.inc"
INCLUDE "include/entity_script.inc"

/* Entity Script Calling Convention:

bc - completely static, *DO NOT MODIFY*
de - used for input/output between certain functions, otherwise volatile.
a, hl - completely volatile, use however you like

*/

SECTION "Entity Script Handler", ROM0

; Handles the entity's script.
; @ bc: Entity index.
HandleEntityScript::
    ld hl, wEntityFieldArray
    add hl, bc
    ld a, [hli]
    ld h, [hl]
    ld l, a
    or a, h
    ret z

    ld a, [hl]
    call HandleJumpTable
        ASSERT ENTITY_SCRIPT_YIELD == 0
        dw ScriptYield
        ASSERT ENTITY_SCRIPT_JUMP == 1
        dw ScriptJump
        ASSERT ENTITY_SCRIPT_SETA == 2
        dw ScriptSetArray
        ASSERT ENTITY_SCRIPT_SETF == 3
        dw ScriptSetField
        ASSERT ENTITY_SCRIPT_SETM == 4
        dw ScriptSetMemory

; Script handlers. Each takes `bc` as input.

ScriptYield:
    ld a, 1
    ldh [hScriptOffset], a
; Used to grab, increment, and store the pointer, for when the code doesn't make
; doing so convinient.
IncrementScriptPointer:
    ; Load pointer
    ld hl, wEntityFieldArray
    add hl, bc
    ld a, [hli]
    ld d, [hl]
    ld e, a
    ; Add offset
    ldh a, [hScriptOffset]
    add a, e
    ld e, a
    adc a, d
    sub a, e
    ld d, a
    ; Store pointer
    ld a, d
    ld [hld], a
    ld [hl], e
    ret

ScriptJump:
    ; Grab the script pointer
    ld hl, wEntityFieldArray
    add hl, bc
    ld a, [hli]
    ld d, [hl]
    ld e, a
    inc de
    ; Load the high byte of the destination - BE saves us a dec here.
    ld a, [de]
    inc de
    ld [hld], a
    ; Load the high byte.
    ld a, [de]
    ld [hl], a
    jr HandleEntityScript

; Set a given member of the entity's structure.
ScriptSetArray:
    ; Grab the script pointer.
    ld hl, wEntityFieldArray
    add hl, bc
    ld a, [hli]
    ld d, [hl]
    ld e, a
    ; Advance to the field.
    inc de
    ld hl, wEntityArray
    add hl, bc
.setjump ; The rest can be re-used by ScriptSetField, so give it a spot to enter.
    ; Add the field offset to the entity structure.
    ld a, [de]
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; Load the target value into the field.
    inc de
    ld a, [de]
    ld [hl], a
    ; Save script pointer
    inc de
    ld hl, wEntityFieldArray
    add hl, bc
    ld a, e
    ld [hli], a
    ld [hl], d
    jr HandleEntityScript

; Set a given member of the entity's fields.
ScriptSetField:
    ; Grab the script pointer.
    ld hl, wEntityFieldArray
    add hl, bc
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ; Advance to the field.
    inc de
    jr ScriptSetArray.setjump ; re-use some code!

; Set an arbitrary memory address
ScriptSetMemory:
    ; Grab the script pointer.
    ld hl, wEntityFieldArray
    add hl, bc
    ld a, [hli]
    ld h, [hl]
    ld l, a
    inc hl
    ; Load the address
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ; Load the value and store
    ld a, [hli]
    ld [de], a
    ; Offset script pointer
    ld a, 3
    ldh [hScriptOffset], a
    call IncrementScriptPointer
    jp HandleEntityScript


SECTION "Entity Script Fields", WRAM0, ALIGN[8]

; Extra variables for entities to use. The first two bytes are used as a script
; pointer if the entity has a script.
wEntityFieldArray::
    ds sizeof_Entity * MAX_ENTITIES

SECTION "Script Offset Byte", HRAM

hScriptOffset:
    ds 1