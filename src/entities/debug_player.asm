
INCLUDE "include/directions.inc"
INCLUDE "include/entities.inc"

SECTION "Hit Dummy", ROMX

DUMMY_STATE_IDLE EQU 0
DUMMY_STATE_HURT EQU 1

HitDummyScript::
    find_entity Entity_InvTimer
    ld a, [hl]
    and a, a
    jr nz, .decTimer
    find_entity Entity_CollisionData
    ld a, [hl] ; Load the collision data
    and a, a
    jr z, .noDamage
    xor a, a
    ld [hl], a
    find_entity Entity_State
    ld a, DUMMY_STATE_HURT
    ld [hli], a ; Set state to hurt
    ld a, 15
    ld [hli], a ; Set 15 Frame knockback timer
    ; Next, set the timer. This falls through.
    ld a, 60 + 1 ; 1 second Inv Timer
.decTimer
    dec a
    ld [hl], a ; Dec and restore the Inv Timer
.noDamage

    find_entity Entity_State
    ld a, [hli]
    dec a
    ret nz
    ld a, [hl]
    dec a
    ld [hld], a
    jr nz, .skipFinish
    xor a, a
    ld [hl], a
.skipFinish
    find_entity
    jp MoveAndSlide