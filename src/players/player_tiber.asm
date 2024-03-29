INCLUDE "banks.inc"
INCLUDE "directions.inc"
INCLUDE "entity.inc"
INCLUDE "hardware.inc"
INCLUDE "players.inc"
INCLUDE "scripting.inc"
INCLUDE "text.inc"

RSSET 4
DEF SWORD_WINDUP_TIME RB 4
DEF SWORD_DRAW_TIME   RB 4
DEF SWORD_OUTDEL_TIME RB 4
DEF SWORD_DAMAGE_TIME RB 0

SECTION "Tiber Definition", ROM0

PlayerTiber::
    far_pointer TiberPlayerLogic
    far_pointer TiberMetasprites

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
    ld hl, .stateTable
    jp HandleJumpTable

.stateTable
    ASSERT PLAYER_STATE_NORMAL == 0
    DW TiberActiveNormal
    ASSERT PLAYER_STATE_HURT == 1
    DW TiberDamage
    ASSERT PLAYER_STATE_ITEM0 == 2
    DW TiberSword
    ASSERT PLAYER_STATE_ITEM1 == 3
    DW TiberShield
    ASSERT PLAYER_STATE_ITEM2 == 4
    DW TiberSword
    ASSERT PLAYER_STATE_ITEM3 == 5
    DW TiberSword

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
    ld hl, .aiStateTable
    jp HandleJumpTable

.aiStateTable
    ASSERT ALLY_MODE_FOLLOW == 0
    DW TiberAIFollow

.skipAISwitch
    ld hl, wTiber
    call PlayerInteractionCheck

    ld hl, wTiber
    call NPCInteractionCheck

    ; Attack check
    ld a, [wPlayerEquipped.tiber]
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
    call LookupMapData
    ld a, [hl]
    ldh [hCurrentTile], a
    call ScreenTransitionCheck
    ldh a, [hCurrentTile]
    jp WarpTileCheck

TiberDamage:
    ld a, [wIsTiberShielded]
    and a, a
    jr z, .noShield
        ; Ensure we are facing in the right direction.
        ld a, [wTiber_Direction]
        ld hl, wTiber_YVel
        and a, a
        jr z, .positive
        dec a
        jr z, .negative
        inc l
        dec a
        jr nz, .negative
.positive
        ld a, [hl]
        bit 7, a
        jr z, .noShield
        jr .success
.negative
        ld a, [hl]
        bit 7, a
        jr nz, .noShield
.success
        ; Halve knockback
        ld hl, wTiber_YVel
        sra [hl]
        inc l
        sra [hl]

        xor a, a
        ld [wIsTiberShielded], a
        ld [wTiber_CollisionData], a
        ld a, INVINCIBLE_FRAMES / 12
        ld [wTiber_InvTimer], a
.noShield
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
    ld a, FRAMEOFF_SWORD_SWOOSH
    ld [wTiber_Frame], a
    ld a, [wTiber_Timer]
    cp a, SWORD_OUTDEL_TIME ; start damage after 6 frames
    ret c
    ld a, FRAMEOFF_SWORD
    ld [wTiber_Frame], a

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
    call VectorFromHLToDE
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

TiberShield:
    ldh a, [hCurrentKeys]
    and a, PADF_A | PADF_B
    jr nz, .noRelease
        ASSERT PLAYER_STATE_NORMAL == 0
        xor a, a ; ld a, PLAYER_STATE_NORMAL
        ld [wIsTiberShielded], a
        ld [wTiber_State], a
        ret
.noRelease
    ld a, FRAMEOFF_SHIELD
    ld [wTiber_Frame], a
    ld a, 1
    ld [wIsTiberShielded], a
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
    jp MoveAndSlide

SECTION "Tiber Dialogue", ROMX

TiberGeneric::
    pause
    jump_if wPlayerWaitLink.tiber, wActivePlayer, \
        .waitDialogue

.followDialogue
    tiber_text .followText
    question_branch .end
    call_function PlayerSetWaitLink.tiber
    end_script

.waitDialogue
    tiber_text .waitText
    question_branch .end
    set_pointer wPlayerWaitLink.tiber, PLAYER_TIBER
.end
    end_script


.waitText
    say "What do you\n"
    say "need?\n"

    ask "Nothing.\n"
    ask "Wait here."
    end_ask

.followText
    say "Come on, let's\n"
    say "go.\n"

    ask "Not yet.\n"
    ask "Follow me."
    end_ask

SECTION "Tiber Using Shield", WRAM0
wIsTiberShielded::
    DS 1

SECTION UNION "Volatile", HRAM
hCurrentTile:
    DS 1