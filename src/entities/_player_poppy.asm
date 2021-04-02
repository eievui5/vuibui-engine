
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
        case PLAYER_STATE_BOW, PoppyBow
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
    call LookupMapData
    ld a, [hl]
    ldh [hCurrentTile], a
    call ScreenTransitionCheck
    ldh a, [hCurrentTile]
    jp WarpTileCheck

; Damage should be a function, not a per-player state.
PoppyDamage:
    ld bc, PLAYER_POPPY * sizeof_Entity
    jp PlayerDamage

PoppyBow:
    ld a, [wPoppyActiveArrows]
    cp a, 2
    jr z, .forceExit

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
    cp a, 2 + 1 ; 2 frame delay...
    ret c
    ld a, [wPoppy_Frame]
    add a, FRAMEOFF_SWING
    ld [wPoppy_Frame], a
    ld a, [wPoppy_Timer]
    cp a, 16 + 2 + 1 ; 16 frame action!
    ret c
    ld hl, wPoppyArrow0
    ASSERT HIGH(PoppyArrow) != $00
    ld a, [hl]
    and a, a
    jr z, .spawn
    ld hl, wPoppyArrow1
.spawn
    ld a, HIGH(PoppyArrow)
    ld [hli], a
    ld a, LOW(PoppyArrow)
    ld [hli], a
    ld a, [wPoppy_YPos]
    ld [hli], a
    ld a, [wPoppy_XPos]
    ld [hli], a
    inc l 
    inc l
    ld a, POPPY_ARROW_DAMAGE ; Poppy's arrow Damage
    ld [hld], a
    dec l
    ld a, [wPoppyActiveArrows]
    inc a
    ld [wPoppyActiveArrows], a
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
    ld a, -4
    ld [hl], a
    ld b, DIR_LEFT
    jr .storeFrameDec
.down
    ld a, 4
    ld [hl], a
    ld b, DIR_DOWN
    jr .storeFrame
.up
    ld a, -4
    ld [hl], a
    ld b, DIR_UP
    jr .storeFrame
.right
    ld a, 4
    ld [hl], a
    ld b, DIR_RIGHT
.storeFrameDec
    dec l
.storeFrame
    ld a, Entity_Frame - Entity_YVel
    add a, l
    ld l, a
    ld a, b
    ld [hl], a
.forceExit
    ASSERT PLAYER_STATE_NORMAL == 0
    xor a, a
    ld [wPoppy_State], a
    ret

PoppyAIFollow:
    ld bc, PLAYER_POPPY * sizeof_Entity
    ld e, POPPY_FOLLOW_DISTANCE
    call PlayerAIFollow
    
    ld hl, wPoppy
    jp MoveAndSlide

SECTION "Poppy Vars", WRAM0
; Used to keep track of how many arrows are active at a time.
wPoppyActiveArrows::
    ds 1

SECTION UNION "Volatile", HRAM
hCurrentTile:
    ds 1