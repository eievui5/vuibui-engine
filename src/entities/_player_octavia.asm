INCLUDE "include/banks.inc"
INCLUDE "include/bool.inc"
INCLUDE "include/damage.inc"
INCLUDE "include/directions.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/players.inc"
INCLUDE "include/switch.inc"

/*  Octavia's functions.

    @ Logic
    @ States
    @ AI
    @ Rendering

*/

SECTION "Octavia AI", ROMX

OctaviaPlayerLogic::
    ; Always start by offsetting frame by facing direction
    ld a, [wOctavia_Direction]
    ld [wOctavia_Frame], a

    ; Check for damage
    ld a, [wOctavia_InvTimer] ; Check the timer...
    and a, a ; If the inv timer is running, no damage!
    jr z, .acceptDamage
    ; If we're here and not accepting damage, set it to 0
    xor a, a
    ld [wOctavia_CollisionData], a
    ld a, [wOctavia_InvTimer]
    jr .decTimer
.acceptDamage
    ld a, [wOctavia_CollisionData] ; Load the collision data
    and a, a
    jr z, .noDamage
    ld a, PLAYER_STATE_HURT
    ld [wOctavia_State], a 
    ld a, KNOCK_FRAMES
    ld [wOctavia_Timer], a
    ; Next, set the timer. This falls through.
    ld a, INVINCIBLE_FRAMES + 1
.decTimer
    dec a
    ld [wOctavia_InvTimer], a
.noDamage
.activeControl

    ld a, [wOctavia_State]
    switch
        case PLAYER_STATE_NORMAL, OctaviaActiveNormal
        case PLAYER_STATE_HURT, OctaviaDamage
        case PLAYER_STATE_FIRE_WAND, OctaviaRod.fire
        case PLAYER_STATE_ICE_WAND, OctaviaRod.ice
        case PLAYER_STATE_SHOCK_WAND, OctaviaRod.shock
        case PLAYER_STATE_HEAL_WAND, OctaviaRod.heal
    end_switch

OctaviaActiveNormal:

    ; Is this the active player?
    ld a, [wActivePlayer]
    ASSERT PLAYER_OCTAVIA == 0
    and a, a
    jr z, .skipAISwitch ; For now, skip processing if the entity is not active.

    ld a, [wActivePlayer]
    ld b, a
    ld a, [wPlayerWaitLink.octavia]
    cp a, b
    ret nz
    ld a, [wAllyLogicMode]
    switch
        case ALLY_MODE_FOLLOW, OctaviaAIFollow
    end_switch

.skipAISwitch
    ; Attack check
    ld a, [wPlayerEquipped.octavia]
    ld b, a
    ld hl, wOctavia_State
    call UseItemCheck
    ld hl, wOctavia
    call InteractionCheck
.activeMove
    ld bc, PLAYER_OCTAVIA * sizeof_Entity
    call PlayerInputMovement
.transitionCheck
    ld a, [wOctavia_YPos]
    ld b, a
    ld a, [wOctavia_XPos]
    ld c, a
    call LookupMapData
    ld a, [hl]
    ldh [hCurrentTile], a
    call ScreenTransitionCheck
    ldh a, [hCurrentTile]
    jp WarpTileCheck

; Damage should be a function, not a per-player state.
OctaviaDamage:
    ld bc, PLAYER_OCTAVIA * sizeof_Entity
    jp PlayerDamage

OctaviaRod:
.heal
    ld d, 1
    ld e, SPELL_GFX_HEAL
    ld b, TRUE ; b is true if the spell should heal players.
    ld c, 1
    jr .shootHeal
.fire
    ld d, DAMAGE_EFFECT_FIRE | OCTAVIA_FIRE_DAMAGE
    ld e, SPELL_GFX_FIRE
    ld c, 0
    jr .shoot
.ice
    ld d, DAMAGE_EFFECT_ICE | OCTAVIA_ICE_DAMAGE
    ld e, SPELL_GFX_ICE
    ld c, 2
    jr .shoot
.shock
    ld d, DAMAGE_EFFECT_SHOCK | OCTAVIA_SHOCK_DAMAGE
    ld e, SPELL_GFX_SHOCK
    ld c, 1
.shoot
    ld b, FALSE ; b is false if the spell should hurt enemies.
.shootHeal
    ld a, [wOctaviaSpellActive]
    and a, a
    jr nz, .forceExit
    ld a, e
    ld [wTargetSpellGraphic], a

    ld a, [wOctavia_Flags]
    and a, a
    jr nz, .skipInit ; Are the flags == 0? initiallize!
    ld [wOctavia_Timer], a
    inc a
    ld [wOctavia_Flags], a
.skipInit
    ld a, [wOctavia_Timer]
    inc a
    ld [wOctavia_Timer], a
    cp a, 4 + 1 ; 4 frame delay...
    ret c
    ld a, [wOctavia_Frame]
    add a, FRAMEOFF_SWING
    ld [wOctavia_Frame], a
    ld a, [wOctavia_Timer]
    cp a, 8 + 4 + 1 ; 8 frame action!
    ret c
    ld a, TRUE
    ld [wOctaviaSpellActive], a
    ld hl, wOctaviaSpell
    ld a, HIGH(OctaviaSpell)
    ld [hli], a
    ld a, LOW(OctaviaSpell)
    ld [hli], a
    ld a, [wOctavia_YPos]
    ld [hli], a
    ld a, [wOctavia_XPos]
    ld [hli], a
    ld a, d
    ld [wOctaviaSpell_CollisionData], a ; Set the projectile's damage
    ld a, b
    ld [wOctaviaSpell_Flags], a
    ld a, c
    ld [wOctaviaSpell_Frame], a
    ASSERT PLAYER_STATE_NORMAL == 0
    xor a, a
    ld [wOctavia_State], a
    ld a, [wOctavia_Direction]
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
.forceExit
    ASSERT PLAYER_STATE_NORMAL == 0
    xor a, a
    ld [wOctavia_State], a
    ret

OctaviaAIFollow:
    ld a, [wActivePlayer]
    cp a, PLAYER_POPPY
    ld e, FOLLOW_CLOSE ; Octavia should be close when Poppy is active
    jr z, .follow
    ld e, FOLLOW_FAR ; And far when Tiber is active.
.follow
    ld bc, PLAYER_OCTAVIA * sizeof_Entity
    call PlayerAIFollow
    
    ld hl, wOctavia
    jp MoveAndSlide

; Updates the current spell graphic during VBlank if needed.
OctaviaUpdateSpellGraphic::
    ld a, [wActiveSpellGraphic]
    ld b, a
    ld a, [wTargetSpellGraphic]
    cp a, b
    ret z
    ld [wActiveSpellGraphic], a
    dec a
    add a, a ; a * 2
    swap a  ; a * 32
    ld hl, GfxPlayerSpells
    add_r16_a hl
    ld a, BANK(GfxPlayerSpells)
    swap_bank
    ld bc, 32 ; Size of 2 tiles
    ld de, VRAM_TILES_OBJ + TILE_PLAYER_SPELL * $10
    jp memcopy

SECTION "Octavia Vars", WRAM0
wActiveSpellGraphic:
    ds 1
wTargetSpellGraphic:
    ds 1

wOctaviaSpellActive::
    ds 1

SECTION UNION "Volatile", HRAM
hCurrentTile:
    ds 1
; Used to cache damage and frame of the current spell
hSpellDamage:
    ds 1
hSpellFrame:
    ds 1