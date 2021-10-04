
INCLUDE "directions.inc"
INCLUDE "entity.inc"

SECTION "Hit Dummy", ROMX

DUMMY_STATE_IDLE EQU 0
DUMMY_STATE_HURT EQU 1

HitDummyScript::
    ld hl, wEntityArray + Entity_InvTimer
    add hl, bc
    ld a, [hl]
    and a, a
    jr nz, .decTimer
    ld hl, wEntityArray + Entity_CollisionData
    add hl, bc
    ld a, [hl] ; Load the collision data
    and a, a
    jr z, .noDamage
    xor a, a
    ld [hl], a
    ld hl, wEntityArray + Entity_State
    add hl, bc
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

    ld hl, wEntityArray + Entity_State
    add hl, bc
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
    ld hl, wEntityArray
    jp MoveAndSlide