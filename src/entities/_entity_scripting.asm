INCLUDE "include/entity.inc"
INCLUDE "include/entity_script.inc"

SECTION "Entity Script Handler", ROM0

; Handles the entity's script.
; @ bc: Entity index.
HandleEntityScript::
    ld h, HIGH(wEntityFieldArray)
    ld l, c
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
        ASSERT ENTITY_SCRIPT_KILL == 5
        dw ScriptKill
        ASSERT ENTITY_SCRIPT_ADDA == 6
        dw ScriptAddArray
        ASSERT ENTITY_SCRIPT_ADDF == 7
        dw ScriptAddField
        ASSERT ENTITY_SCRIPT_MOVE == 8
        dw ScriptMove
        ASSERT ENTITY_SCRIPT_GETM == 9
        dw ScriptGetMemory
        ASSERT ENTITY_SCRIPT_CHASE_PLAYER == 10
        dw ScriptChasePlayer
        ASSERT ENTITY_SCRIPT_ANIMATE == 11
        dw ScriptAnimate
        ASSERT ENTITY_SCRIPT_INLINE == 12
        dw ScriptInline
        ASSERT ENTITY_SCRIPT_FOR == 13
        dw ScriptFor
        ASSERT ENTITY_SCRIPT_RANDF == 14
        dw ScriptRandField
        ASSERT ENTITY_SCRIPT_ATTACK_PLAYER == 15
        dw ScriptAttackPlayer
        ASSERT ENTITY_SCRIPT_IF_NEG == 16
        dw ScriptIfNegative
        ASSERT ENTITY_SCRIPT_DEATH_PARTICLES == 17
        dw ScriptDeathParticles

; Script handlers. Each takes `bc` as input.

ScriptYield:
    ld a, 1
; Used to grab, increment, and store the pointer, for when the code doesn't make
; doing so convinient.
IncrementScriptPointer:
    ldh [hScriptOffset], a
    ; Load pointer
    ld h, HIGH(wEntityFieldArray)
    ld l, c
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
    ld h, HIGH(wEntityFieldArray)
    ld l, c
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
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld d, [hl]
    ld e, a
    ; Advance to the field.
    inc de
    ld h, HIGH(wEntityArray)
    ld l, c
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
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, e
    ld [hli], a
    ld [hl], d
    jr HandleEntityScript

; Set a given member of the entity's fields.
ScriptSetField:
    ; Grab the script pointer.
    ld h, HIGH(wEntityFieldArray)
    ld l, c
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
    ld h, HIGH(wEntityFieldArray)
    ld l, c
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
    call IncrementScriptPointer
    jp HandleEntityScript

; Remove the entity from the entity array
ScriptKill:
    ld h, HIGH(wEntityArray)
    ld l, c
    xor a, a
    ld d, sizeof_Entity
    ; memset_small
:   ld [hli], a
    dec d
    jr nz, :-

    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld d, sizeof_Entity
    ; memset_small
:   ld [hli], a
    dec d
    jr nz, :-
    ret

ScriptAddArray:
    ; Grab the script pointer.
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld d, [hl]
    ld e, a
    ; Advance to the field.
    inc de
    ld h, HIGH(wEntityArray)
    ld l, c
.addjump ; The rest can be re-used by ScriptSetField, so give it a spot to enter.
    ; Add the field offset to the entity structure.
    ld a, [de]
    add a, l
    ld l, a
    ; Add the target value into the field.
    inc de
    ld a, [de]
    add a, [hl]
    ld [hl], a
    ; Save script pointer
    inc de
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, e
    ld [hli], a
    ld [hl], d
    jp HandleEntityScript

; Set a given member of the entity's fields.
ScriptAddField:
    ; Grab the script pointer.
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ; Advance to the field.
    inc de
    jr ScriptAddArray.addjump ; re-use some code!

ScriptMove:
    ld h, HIGH(wEntityArray)
    ld l, c
    push bc
    call MoveAndSlide
    pop bc
    ld a, 1
    call IncrementScriptPointer
    jp HandleEntityScript

; Get an arbitrary memory address
ScriptGetMemory:
    ; Grab the script pointer.
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld h, [hl]
    ld l, a
    inc hl
    ; Load the address
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ; Load the store location
    ld a, [hl]
    ld h, HIGH(wEntityFieldArray)
    add a, c
    ld l, a
    ; Load and store
    ld a, [de]
    ld [hl], a
    ; Offset script pointer
    ld a, 3
    call IncrementScriptPointer
    jp HandleEntityScript

; This function does some weird swapping of `hl` and `de`, could be optimized.
ScriptChasePlayer:
    ld a, [wActivePlayer]
    ; Grab that player's position
    ASSERT sizeof_Entity == 16
    swap a
    add a, LOW(wPlayerArray + Entity_YPos)
    ld l, a
    ld h, HIGH(wPlayerArray)
    ld a, [hli]
    ld e, [hl] ; X in Low
    ld d, a ; Y in High

    ld h, HIGH(wEntityArray)
    ld l, c
    ASSERT Entity_YPos == 2
    inc l
    inc l
    ld a, [hli]
    ld l, [hl] ; X in Low
    ld h, a ; Y in High

    call VectorFromHLToDE
    ; Divide the vector to move at 1 pixel per frame.
    sra h ; -h / 2
    sra l ; -l / 2
    ld d, h ; y
    ld e, l ; x

    ld hl, wEntityArray + Entity_YVel
    add hl, bc
    ld a, d ; load y into YVel
    ld [hli], a
    ld [hl], e

    ASSERT Entity_XVel + 3 == Entity_Direction
    inc l
    inc l
    inc l
    call GetDistanceDirection
    ld [hl], a

    ld h, HIGH(wEntityArray)
    ld l, c
    push bc
    call MoveAndSlide
    pop bc

    ld a, 1
    call IncrementScriptPointer
    jp HandleEntityScript

ScriptAnimate:
    ; Grab the script pointer.
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld d, [hl]
    ld e, a
    inc de
    ld a, [de]
    ; Offset to use the supplied timer
    ld hl, wEntityFieldArray + 2 ; Skip script pointer
    add a, c ; add hl, bc
    add a, l
    ld l, a
    inc [hl]

    inc de
    ld a, [de] ; Grab mask
    inc de
    and a, [hl] ; Mask timer
    ; Flip around the frame depending on the result.
    jr nz, .skipframe
    inc de ; Skip a frame
    ld a, [de]
    jr .setframe
.skipframe
    ld a, [de]
    inc de
.setframe
    inc de
    ld hl, wEntityArray + Entity_Frame
    add hl, bc
    ld [hl], a

    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, e
    ld [hli], a
    ld [hl], d

    jp HandleEntityScript

ScriptInline:
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; Offset by the size of the inline code
    inc hl
    ld a, [hli]
    push hl
    call IncrementScriptPointer
    pop hl
    push bc
    rst _hl_
    pop bc
    jp HandleEntityScript

ScriptFor:
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ; Grab Field
    inc de
    ld a, [de]
    ; If field is negative find the abs and use the entity array.
    bit 7, a
    jr z, .field
    ; abs a
    cpl
    inc a
    ld h, HIGH(wEntityArray)
.field
    ; Add field to Field Array
    add a, c
    ld l, a
    inc de
    ; Decrement counter & check for 0
    ld a, [hl]
    dec [hl]
    and a, a ; check for 0 after dec
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    jr z, .jump
    inc de
    inc de
    ld a, e
    ld [hli], a
    ld [hl], d
    jp HandleEntityScript

.jump
    ld a, [de]
    inc de
    ld [hli], a
    ld a, [de]
    ld [hl], a
    jp HandleEntityScript

ScriptRandField:
    call Rand
    ld b, 0
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld h, [hl]
    ld l, a
    inc hl
    ; Mask result
    ld a, [hli]
    and a, d
    ld d, a
    ; Grab result field
    ld a, [hli]
    ld h, HIGH(wEntityFieldArray)
    add a, c ; add hl, bc
    add a, 2
    ld l, a
    ; Store result
    ld a, d
    ld [hl], a
    ld a, 3
    call IncrementScriptPointer
    jp HandleEntityScript

ScriptAttackPlayer:
    ld h, HIGH(wEntityArray)
    ld a, Entity_YPos
    add a, c
    ld l, a
    ld a, [hli]
    ld d, a
    ld e, [hl]
    call CheckPlayerCollision
    ld a, h
    or a, l
    jr z, .noPlayer

    ASSERT Entity_YPos == 2
    inc l
    inc l
    ld a, [hli]
    ld d, a ; Player Y
    ld a, [hli]
    ld e, a ; Player X
    push hl ; Save Player, set at velocity
        ld h, HIGH(wEntityArray)
        ld l, c
        inc l
        inc l
        ld a, [hli]
        ld l, [hl] ; Self X
        ld h, a ; Self Y
        call VectorFromHLToDE
    pop de
    ld a, h
    ld [de], a
    inc de
    ld a, l
    ld [de], a
    inc de
    ; Grab damage input
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld h, [hl]
    ld l, a
    inc hl
    ; If the input is negative, it is a field
    ld a, [hl]
    bit 7, a
    jr z, .noField
        ; abs a
        cpl
        inc a
        ld h, HIGH(wEntityFieldArray)
        add a, c
        ld l, a
        ld a, [hl]
.noField
    ld [de], a ; Store the damage in the player's collision data

.noPlayer
    ld a, 2
    call IncrementScriptPointer
    jp HandleEntityScript

ScriptIfNegative:
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld h, [hl]
    ld l, a
    inc hl
    ld a, [hl]
    ld h, HIGH(wEntityFieldArray)
    ; If argument is negative, find abs and index into entity array
    bit 7, a
    jr z, .field
        cpl
        inc a
        ld h, HIGH(wEntityArray)
.field
    add a, c
    ld l, a
    ld a, [hl] ; Grab the value
    rla ; Check if negative
    jr nc, .false
; true
    ; Continue if true
    ld a, 4
    call IncrementScriptPointer
    jp HandleEntityScript
.false
    ; Jump if false
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld e, a
    ld a, [hld]
    ld d, a
    inc de
    inc de
    ld a, [de]
    ld [hli], a
    inc de
    ld a, [de]
    ld [hl], a
    jp HandleEntityScript

ScriptDeathParticles:
    ld h, HIGH(wEntityArray)
    ld l, c
    ld a, HIGH(DeathParticle)
    ld [hli], a
    ld [hl], LOW(DeathParticle)
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, LOW(DeathParticleScript)
    ld [hli], a
    ld [hl], HIGH(DeathParticleScript)
    ret

SECTION "Entity Script Fields", WRAM0, ALIGN[8]

; Extra variables for entities to use. The first two bytes are used as a script
; pointer if the entity has a script.
wEntityFieldArray::
    ds sizeof_Entity * MAX_ENTITIES

SECTION "Script Offset Byte", HRAM

hScriptOffset:
    ds 1