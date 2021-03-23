
INCLUDE "include/directions.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/players.inc"
INCLUDE "include/switch.inc"

SECTION "Poppy AI", ROMX

PoppyPlayerLogic::
    ; Always start by offsetting frame by facing direction
    ld a, [wPoppy_Direction]
    ld [wPoppy_Frame], a

    ; Check for damage
    ld a, [wPoppy_InvTimer] ; Check the timer...
    and a, a ; If the inv timer is running, no damage!
    jr z, .acceptDamage
    ; If we're here and not accepting damage, set it to 0
    xor a, a
    ld [wPoppy_CollisionData], a
    ld a, [wPoppy_InvTimer]
    jr .decTimer
.acceptDamage
    ld a, [wPoppy_CollisionData] ; Load the collision data
    and a, a
    jr z, .noDamage
    ld a, PLAYER_STATE_HURT
    ld [wPoppy_State], a 
    ld a, KNOCK_FRAMES
    ld [wPoppy_Timer], a
    ; Next, set the timer. This falls through.
    ld a, INVINCIBLE_FRAMES + 1
.decTimer
    dec a
    ld [wPoppy_InvTimer], a
.noDamage
.activeControl
    ld a, [wPoppy_State]
    switch
        case PLAYER_STATE_NORMAL, PoppyActiveNormal
        case PLAYER_STATE_HURT, PoppyDamage
        case PLAYER_STATE_FIRE_WAND, PoppyFireRod
    end_switch

PoppyActiveNormal: ; How to move.

    ; Is this the active player?
    ld a, [wActivePlayer]
    ASSERT PLAYER_POPPY == 1
    dec a
    jr z, .skipAISwitch

    ld a, [wActivePlayer]
    ld b, a
    ld a, [wPlayerWaitLink.poppy]
    cp a, b
    ret nz
    ld a, [wAllyLogicMode]
    switch
        case ALLY_MODE_FOLLOW, PoppyAIFollow
    end_switch
    
.skipAISwitch
    ; Attack check
    ld a, [wPlayerEquipped.poppy]
    ld b, a
    ld hl, wPoppy_State
    call UseItemCheck
    ld hl, wPoppy
    call InteractionCheck
.activeMove
    ld bc, PLAYER_POPPY * sizeof_Entity
    call PlayerInputMovement
.transitionCheck
    ld a, [wPoppy_YPos]
    ld b, a
    ld a, [wPoppy_XPos]
    ld c, a
    jp ScreenTransitionCheck

; Damage should be a function, not a per-player state.
PoppyDamage:
    ld bc, PLAYER_POPPY * sizeof_Entity
    jp PlayerDamage

PoppyFireRod:
    ld a, [wPoppy_Flags]
    and a, a
    jr nz, .skipInit ; Are the flags == 0? initiallize!
    ld [wPoppy_Timer], a
    inc a
    ld [wPoppy_Flags], a
.skipInit
    ld a, [wPoppy_Timer]
    inc a
    ld [wPoppy_Timer], a
    cp a, 4 + 1 ; 4 frame delay...
    ret c
    ld a, [wPoppy_Frame]
    add a, FRAMEOFF_SWING
    ld [wPoppy_Frame], a
    ld a, [wPoppy_Timer]
    cp a, 8 + 4 + 1 ; 8 frame action!
    ret c
    ASSERT PLAYER_STATE_NORMAL == 0
    ld a, [wPoppy_YPos]
    ld c, a
    ld a, [wPoppy_XPos]
    ld b, a
    ld de, PlayerSpell
    call SpawnEntity
    xor a, a
    ld [wPoppy_State], a
    ld a, [wPoppy_Direction]
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

PoppyAIFollow:
    ld bc, PLAYER_POPPY * sizeof_Entity
    ld e, POPPY_FOLLOW_DISTANCE
    call PlayerAIFollow
    
    ld hl, wPoppy
    jp MoveAndSlide