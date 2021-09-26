INCLUDE "include/directions.inc"
INCLUDE "include/entity.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/players.inc"
INCLUDE "include/scripting.inc"
INCLUDE "include/sfx.inc"
INCLUDE "include/text.inc"

/*  Octavia's functions.

    @ Logic
    @ States
    @ AI
    @ Rendering

*/

SECTION "Octavia AI", ROMX

OctaviaPlayerLogic::
    xor a, a
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
    ld hl, .stateJumpTable
    jp HandleJumpTable

.stateJumpTable
    ASSERT PLAYER_STATE_NORMAL == 0
    dw OctaviaActiveNormal
    ASSERT PLAYER_STATE_HURT == 1
    dw OctaviaDamage
    ASSERT PLAYER_STATE_ITEM0 == 2
    dw OctaviaRod.fire
    ASSERT PLAYER_STATE_ITEM1 == 3
    dw OctaviaRod.ice
    ASSERT PLAYER_STATE_ITEM2 == 4
    dw OctaviaRod.shock
    ASSERT PLAYER_STATE_ITEM3 == 5
    dw OctaviaRod.heal

/*

WHAT SHOULD DYING DO?

 - Player drops to the ground, allies must revive them
    Pros
        Each player gets a chance to fight
        Health can be made lower
    Cons
        Makes you rapidly switch upon death; may be dissorienting.
        Could be frustrating to die often if health is low, 
        or unbalanced to have 3x as many chances if health is high
        Doesn't work right if players are in different rooms or disabled.
 - Game over if any player dies
    Pros
        Much easier to program
        Works when players are seperated
    Cons
        Switching characters when close to death would be the best way to stay alive (is this a pro?)
        Only the active player can be damaged (is *this* a pro?)
        Player AI would not be able to be as advanced (... this is a pro for *me*)

*/

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
    ld hl, .aiModesTable
    jp HandleJumpTable

.aiModesTable
    ASSERT ALLY_MODE_FOLLOW == 0
    dw OctaviaAIFollow

.skipAISwitch
    ld hl, wOctavia
    call PlayerInteractionCheck

    ld hl, wOctavia
    call NPCInteractionCheck

    ; Attack check
    ld a, [wPlayerEquipped.octavia]
    ld b, a
    ld hl, wOctavia_State
    call UseItemCheck
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
    ld e, SPELL_HEAL
    ld b, 1 ; b is true if the spell should heal players.
    ld c, 1
    jr .shootHeal
.fire
    ld d, DAMAGE_EFFECT_FIRE | OCTAVIA_FIRE_DAMAGE
    ld e, SPELL_FIRE
    ld c, 0
    jr .shoot
.ice
    ld d, DAMAGE_EFFECT_ICE | OCTAVIA_ICE_DAMAGE
    ld e, SPELL_ICE
    ld c, 2
    jr .shoot
.shock
    ld d, DAMAGE_EFFECT_SHOCK | OCTAVIA_SHOCK_DAMAGE
    ld e, SPELL_SHOCK
    ld c, 1
.shoot
    ld b, 0 ; b is false if the spell should hurt enemies.
.shootHeal
    ld a, [wOctaviaSpellActive]
    and a, a
    jr nz, .forceExit

    ld a, [wOctavia_Flags]
    and a, a
    jr nz, .skipInit ; Are the flags == 0? initiallize!
    ld [wOctavia_Timer], a
    inc a
    ld [wOctavia_Flags], a
    ; Update spell graphic
    ld a, e
    dec a
    add a, a ; a * 2
    swap a ; a * 32
    ; Add `a` to `hl`
    add a, LOW(GfxPlayerSpells)
    ld l, a
    adc a, HIGH(GfxPlayerSpells)
    sub a, l
    ld h, a
    ; This is what you get when you try to refactor old code. Stack usage.
    push bc
    push de
    ld c, 32 ; Size of 2 tiles
    ld de, VRAM_TILES_OBJ + TILE_PLAYER_SPELL * $10
    call vmemcopy_small
    pop bc
    pop de
.skipInit
    ld a, [wOctavia_Timer]
    inc a
    ld [wOctavia_Timer], a
    cp a, 4 + 1 ; 4 frame delay...
    ret c
    ld a, FRAMEOFF_SWING
    ld [wOctavia_Frame], a
    jr z, .playSound ; If this is the first time swinging, play a sound
    ld a, [wOctavia_Timer]
    cp a, 8 + 4 + 1 ; 8 frame action!
    ret c
    ld a, 1
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
    jr z, .pos
    ASSERT DIR_UP == 1
    dec a
    jr z, .neg
    ASSERT DIR_RIGHT == 2
    inc l
    dec a
    jr z, .pos
    ASSERT DIR_LEFT == 3
.neg
    ld a, -3
    ld [hl], a
    ret
.pos
    ld a, 3
    ld [hl], a
    ret
.playSound
    ; Use value in `e` to find SFX
    ld a, SOUND_FLAME - 1
    add a, e
    jp audio_play_fx
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
    ; If tiber is active, check if poppy is waiting
    ld a, PLAYER_POPPY
    call PlayerActivityCheck.waiting
    jr nz, .follow
    ld e, FOLLOW_FAR ; And far when Tiber is active.
.follow
    ld bc, PLAYER_OCTAVIA * sizeof_Entity
    call PlayerAIFollow
    
    ld hl, wOctavia
    jp MoveAndSlide

GfxPlayerSpells::
    ASSERT SPELL_FIRE == 1
    INCBIN "res/gfx/misc/fire.2bpp"
    ASSERT SPELL_ICE == 2
    INCBIN "res/gfx/misc/ice.2bpp"
    ASSERT SPELL_SHOCK == 3
    INCBIN "res/gfx/misc/shock.2bpp"
    ASSERT SPELL_HEAL == 4
    INCBIN "res/gfx/misc/heal.2bpp"

SECTION "Octavia Dialogue", ROMX

OctaviaGeneric::
    pause
    jump_if wPlayerWaitLink.octavia, wActivePlayer, \
        .waitDialogue

.followDialogue
    octavia_text .followText
    question_branch .end
    call_function PlayerSetWaitLink.octavia
    end_script

.waitDialogue
    octavia_text .waitText
    question_branch .end
    set_pointer wPlayerWaitLink.octavia, PLAYER_OCTAVIA
.end
    end_script

.waitText
    say "Yeah? Do you\n"
    say "need something?\n"

    ask "Nevermind.\n"
    ask "Wait here."
    end_ask

.followText
    say "Whenever you're\n"
    say "ready.\n"

    ask "Not yet.\n"
    ask "Follow me."
    end_ask

SECTION "Octavia Vars", WRAM0

; Is there a spell active?
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
