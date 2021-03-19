
INCLUDE "include/directions.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/players.inc"
INCLUDE "include/switch.inc"

SECTION "Tiber AI", ROMX

TiberPlayerLogic::
    ; Always start by offsetting frame by facing direction
    ld a, [wTiber_Direction]
    ld [wTiber_Frame], a

    ; Check for damage
    ld a, [wTiber_InvTimer] ; Check the timer...
    and a, a ; If the inv timer is running, no damage!
    jr z, .acceptDamage
    ; If we're here and not accepting damage, set it to 0
    xor a, a
    ld [wTiber_CollisionData], a
    ld a, [wTiber_InvTimer]
    jr .decTimer
.acceptDamage
    ld a, [wTiber_CollisionData] ; Load the collision data
    and a, a
    jr z, .noDamage
    ld a, PLAYER_STATE_HURT
    ld [wTiber_State], a 
    ld a, KNOCK_FRAMES
    ld [wTiber_Timer], a
    ; Next, set the timer. This falls through.
    ld a, INVINCIBLE_FRAMES + 1
.decTimer
    dec a
    ld [wTiber_InvTimer], a
.noDamage
.activeControl
    ld a, [wTiber_State]
    switch
        case PLAYER_STATE_NORMAL, TiberActiveNormal
        case PLAYER_STATE_HURT, TiberDamage
        case PLAYER_STATE_FIRE_WAND, TiberFireRod
    end_switch

TiberActiveNormal: ; How to move.

    ; Is this the active player?
    ld a, [wActivePlayer]
    cp a, PLAYER_TIBER
    ret nz ; For now, skip processing if the entity is not active.
    
    ; Attack check
    ld a, [wTiberEquipped]
    ld b, a
    ld hl, wTiber_State
    call UseItemCheck
.activeMove
    ld bc, PLAYER_TIBER * sizeof_Entity
    call PlayerInputMovement
.transitionCheck
    ld a, [wTiber_YPos]
    ld b, a
    ld a, [wTiber_XPos]
    ld c, a
    call ScreenTransitionCheck
.activeScroll
    ; Scroll
    ld a, [wTiber_YPos]
    sub a, 80 + 8
    ld e, a
    ld a, [wTiber_XPos]
    sub a, 72 + 8
    ld d, a
    jp SetScrollBuffer
    ret

; Damage should be a function, not a per-player state.
TiberDamage:
    ld bc, PLAYER_TIBER * sizeof_Entity
    jp PlayerDamage

TiberFireRod:
    ld a, [wTiber_Flags]
    and a, a
    jr nz, .skipInit ; Are the flags == 0? initiallize!
    ld [wTiber_Timer], a
    inc a
    ld [wTiber_Flags], a
.skipInit
    ld a, [wTiber_Timer]
    inc a
    ld [wTiber_Timer], a
    cp a, 4 + 1 ; 4 frame delay...
    ret c
    ld a, [wTiber_Frame]
    add a, FRAMEOFF_SWING
    ld [wTiber_Frame], a
    ld a, [wTiber_Timer]
    cp a, 8 + 4 + 1 ; 8 frame action!
    ret c
    ASSERT PLAYER_STATE_NORMAL == 0
    ld a, [wTiber_YPos]
    ld c, a
    ld a, [wTiber_XPos]
    ld b, a
    ld de, PlayerSpell
    call SpawnEntity
    xor a, a
    ld [wTiber_State], a
    ld a, [wTiber_Direction]
    ASSERT DIR_DOWN == 0
    and a, a
    jr z, .down
    ASSERT DIR_UP == 1
    dec a
    jr z, .up
    ASSERT DIR_RIGHT == 2
    inc l
    dec a
    jr z, .right
    ASSERT DIR_LEFT == 3
.left
    ld a, -3
    ld [hl], a
    ret
.down
    ld a, 3
    ld [hl], a ; Copy/pasting this is faster and smaller than jr.
    ret
.up
    ld a, -3
    ld [hl], a
    ret
.right
    ld a, 3
    ld [hl], a
    ret
