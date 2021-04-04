
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
    end_switch

TiberActiveNormal: ; How to move.

    ; Is this the active player?
    ld a, [wActivePlayer]
    cp a, PLAYER_TIBER
    jr z, .skipAISwitch

    ld a, [wActivePlayer]
    ld b, a
    ld a, [wPlayerWaitLink.tiber]
    cp a, b
    ret nz
    ld a, [wAllyLogicMode]
    switch
        case ALLY_MODE_FOLLOW, TiberAIFollow
    end_switch
    
.skipAISwitch
    ; Attack check
    ld a, [wPlayerEquipped.tiber]
    ld b, a
    ld hl, wTiber_State
    call UseItemCheck
    ld hl, wTiber
    call InteractionCheck
.activeMove
    ld bc, PLAYER_TIBER * sizeof_Entity
    call PlayerInputMovement
.transitionCheck
    ld a, [wTiber_YPos]
    ld b, a
    ld a, [wTiber_XPos]
    ld c, a
    call LookupMapData
    ld a, [hl]
    ldh [hCurrentTile], a
    call ScreenTransitionCheck
    ldh a, [hCurrentTile]
    jp WarpTileCheck

; Damage should be a function, not a per-player state.
TiberDamage:
    ld bc, PLAYER_TIBER * sizeof_Entity
    jp PlayerDamage

TiberSword:
    ld hl, wTiber
    call GetEntityTargetPosition
    ld c, 1 ; Load an invalid value into c, so that no entity is ignored.
    call DetectEntity
    inc c

TiberAIFollow:
    ld e, FOLLOW_FAR ; Tiber should always be far.
    ld hl, wActivePlayer
    ld a, [wPlayerWaitLink.octavia]
    cp a, [hl]
    jr nz, .forceClose
    ld a, [wPlayerWaitLink.poppy]
    cp a, [hl]
    jr z, .follow
.forceClose
    ld e, FOLLOW_CLOSE ; Unless one of the allies is waiting
.follow
    ld bc, PLAYER_TIBER * sizeof_Entity
    call PlayerAIFollow
    
    ld hl, wTiber
    jp MoveAndSlide

SECTION UNION "Volatile", HRAM
hCurrentTile:
    ds 1