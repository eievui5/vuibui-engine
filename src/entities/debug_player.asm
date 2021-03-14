
INCLUDE "include/directions.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/macros.inc"
include "include/hardware.inc"

SECTION "Debug Player", ROMX

; An Entity that can be controlled by inputs to test collision
; TODO: When you rewrite the player and finally start working on 
; entities switch to 12.4 bit position vectors.

DebugPlayerScript:

.movement
    FindEntity Entity_YVel 
    ldh a, [hCurrentKeys]
.downCheck
    ld [hl], 0 ; reset Y velocity
    bit PADB_DOWN, a ; Is down pressed?
    jr z, .upCheck
    ld [hl], 1 ; Y velocity of 1
    jr .rightCheck ; Skip .upCheck
.upCheck
    bit PADB_UP, a ; Is up pressed?
    jr z, .rightCheck
    ld [hl], -1 ; Y velocity of -1
.rightCheck
    inc hl ; Move to the X Data
    ld [hl], 0 ; reset X velocity
    bit PADB_RIGHT, a ; Is right pressed?
    jr z, .leftCheck
    ld [hl], 1 ; X velocity of 1
    jr .moveAndSlide
.leftCheck
    bit PADB_LEFT, a ; Is left pressed
    jr z, .moveAndSlide
    ld [hl], -1 ; X velocity of -1


.moveAndSlide
    push bc ; Save entity index
    call MoveAndSlide
    pop bc

    push hl

    ld a, [hli]
    ld d, a
    ld a, [hld]
    ld e, a
    call DetectEntity
    ld a, $FF
    cp a, c ; $FF == no entity
    jr z, .endDetect
    FindEntity Entity_CollisionData
    ld b, b

.endDetect

    pop hl

.render 
    ; Scroll
    SeekAssert Entity_YPos, Entity_XPos, 1
    ld a, [hli]
    sub a, 80 + 8
    ld e, a
    SeekAssert Entity_XPos, Entity_YPos, -1
    ld a, [hld]
    sub a, 72 + 8
    ld d, a
    jp SetScrollBuffer


DUMMY_STATE_IDLE EQU 0
DUMMY_STATE_HURT EQU 1


HitDummyScript::
    FindEntity Entity_CollisionData

.damageCheck
    ld a, [hl]
    and a, a ; Are we damaged?
    jr z, .stateHandler
    xor a
    ld [hl], a ; Clear the damage
    StructSeekUnsafe l, Entity_CollisionData, Entity_State
    ld a, DUMMY_STATE_HURT
    ld [hl], a ; Set the state to hurt

.stateHandler
    FindEntity Entity_State
    ld a, DUMMY_STATE_HURT
    cp a, [hl]
    jr nz, .render
    SeekAssert Entity_State, Entity_Timer, 1
        inc l
    inc [hl]
    ld a, 60
    cp a, [hl]
    jr z, .exitHurtState
    StructSeekUnsafe l, Entity_Timer, Entity_XPos
    inc [hl]
    jr .render
.exitHurtState
    xor a
    ld [hld], a
    ld [hl], a ; Reset timer and state


.render
    ret