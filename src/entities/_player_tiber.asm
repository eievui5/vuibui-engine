
INCLUDE "include/directions.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/players.inc"
INCLUDE "include/switch.inc"

DEF SWORD_WINDUP_TIME = 2 + 1
DEF SWORD_DRAW_TIME   = 2 + 3
DEF SWORD_OUTDEL_TIME = 2 + 5
DEF SWORD_DAMAGE_TIME = 12 + 7

SECTION "Tiber AI", ROMX

TiberPlayerLogic::
    xor a, a
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
        case PLAYER_STATE_SWORD, TiberSword
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
    ld hl, wTiber
    call PlayerInteractionCheck
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
    cp a, SWORD_WINDUP_TIME ; 2 frame windup
    ret c
    ld a, FRAMEOFF_SWING
    ld [wTiber_Frame], a
    ld a, [wTiber_Timer]
    cp a, SWORD_DRAW_TIME ; 2 frame draw
    ret c
    ; ld [wTiber_Frame], FRAMEOFF_SWORD
    cp a, SWORD_OUTDEL_TIME ; start damage after 6 frames
    ret c

    ld hl, wTiber
    call GetEntityTargetPosition
    ld c, 1 ; Load an invalid value into c, so that no entity is ignored.
    call DetectEntity
    and a, a
    jr z, .exit
    ld hl, wEntityArray + Entity_YPos
    add hl, bc
    ld b, h
    ld c, l
    ld a, [hli]
    ld d, a
    ld e, [hl]
    ld hl, wTiber_YPos
    ld a, [hli]
    ld l, [hl]
    ld h, a
    call CalculateKnockback
    ASSERT Entity_YVel - Entity_YPos == 2
    inc c
    inc c
    ld a, h
    ld [bc], a
    inc c
    ld a, l
    ld [bc], a
    inc c
    ld a, 2
    ld [bc], a
.exit
    ld a, [wTiber_Timer]
    cp a, SWORD_DAMAGE_TIME ; You can only swing for X frames.
    ret c
    ASSERT PLAYER_STATE_NORMAL == 0
    xor a, a ; ld a, PLAYER_STATE_NORMAL
    ld [wTiber_State], a
    ret

TiberAIFollow:
    ld e, FOLLOW_FAR ; Tiber should always be far.
    ld hl, wActivePlayer
    ASSERT PLAYER_OCTAVIA == 0
    xor a, a ; ld a, PLAYER_OCTAVIA
    call PlayerActivityCheck.waiting
    jr nz, .forceClose
    ld a, PLAYER_POPPY
    call PlayerActivityCheck.waiting
    jr z, .follow
.forceClose
    ld e, FOLLOW_CLOSE ; Unless one of the allies is waiting
.follow
    ld bc, PLAYER_TIBER * sizeof_Entity
    call PlayerAIFollow
    
    ld hl, wTiber
    jp PlayerMoveAndSlide

SECTION UNION "Volatile", HRAM
hCurrentTile:
    ds 1