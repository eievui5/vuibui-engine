INCLUDE "directions.inc"
INCLUDE "engine.inc"
INCLUDE "entity.inc"
INCLUDE "graphics.inc"
INCLUDE "hardware.inc"
INCLUDE "players.inc"
INCLUDE "scripting.inc"

DEF DEATH_SPIN_SPEED EQU 2
DEF DEATH_SPIN_COUNT EQU 5

SECTION "Player Damage", ROM0

; The common Damage state handling for all players. Includes death and knockback.
PlayerDamage::
    ld h, HIGH(wPlayerArray)
    ld a, Entity_CollisionData
    add a, c
    ld l, a
    ld a, [hl]
    and a, $0F
    jr z, .timer ; No damage left? skip...
    ld d, a
    xor a, a
    ld [hli], a ; Seek to health
    ld a, [hl]
    sub a, d
    jr z, PlayerDeath ; TODO: is there a better way to combine these?
    jr c, PlayerDeath
    ; If damage < health, we're not dead!
    ld [hl], a
.timer
    ld a, Entity_Timer
    add a, c
    ld l, a
    ld a, [hl]
    dec a
    ld [hld], a ; Seek to state
    jr nz, .knockback
    ASSERT PLAYER_STATE_NORMAL == 0
    ; if we're down here, a already = 0
    ld [hl], a
.knockback
    ld hl, wPlayerArray
    add hl, bc
    jp PlayerMoveAndSlide

; Handle the player death animation, including a scripted cutscene section.
PlayerDeath::
    ; Clear enemies so that they don't appear during the animation.
    xor a, a
    ld c, sizeof_Entity * NB_ENTITIES
    ld hl, wEntityArray
    rst MemSetSmall
    ; Clear entity fields
    ld c, sizeof_Entity * NB_ENTITIES
    ld hl, wEntityFieldArray
    rst MemSetSmall

    ; Keep track of the active player so that we can skip them.
    ld a, [wActivePlayer]
    inc a ; Increase by one so that we can use `dec` in a loop.
    ld b, a
    ld c, 3 + 1
    ; Since wActivePlayer will never be -1, we know `a` is "true" right now :)
    ld hl, wPlayerDisabled - 1
    ; Also hide the other players.
.disableOthers
    inc hl
    dec c ; Must check this first since the active player may be skipped.
    jr z, .loadFadeOut
    dec b
    jr z, .disableOthers
    ld [hl], a ; Set disabled flag for this player
    jr .disableOthers

.loadFadeOut
    ; Set target palettes and fade (we use a bit of custom logic here so we
    ; won't offload this to the script).

    ; CGB fading supports excluding objects natively, but for the DMG we'll just
    ; handle this manually.
    ldh a, [hSystem]
    and a, a
    jr nz, .cgbFade
.waitVBlank
            xor a, a
            ld [wNewFrame], a
            ; When main is unhalted we ensure that it will not loop.
            halt
            ld a, [wNewFrame]
            and a, a
            jr z, .waitVBlank
        ld a, [wFrameTimer]
        and a, %11 ; every 4th frame
        jr nz, .waitVBlank
        
        ldh a, [rBGP]
        add a, a ; a << 1
        add a, a ; a << 2
        ldh [rBGP], a
        and a, a
        jr z, .loadScript
        jr .waitVBlank
.cgbFade
        ; Here we can just take advantage of our CGB fading system.
        ld a, $FF
        ld hl, wBCPDTarget
        ld c, sizeof_PALETTE * 8
        rst MemSetSmall
        ; Copy the Objects; we don't want them to change.
        ld c, sizeof_PALETTE * 8
        ld de, wOCPDTarget
        ld hl, wOCPD
        rst MemCopySmall
        ld a, PALETTE_STATE_FADE
        ld [wPaletteState], a

.loadScript

    ASSERT DIR_DOWN == 0
    xor a, a
    ld [wOctavia_InvTimer], a
    ld [wPoppy_InvTimer], a
    ld [wTiber_InvTimer], a
    ld [wScriptVars + 0], a

    ld hl, wActiveScriptPointer
    ld a, BANK(xPlayerDeathScript)
    ld [hli], a
    ld a, LOW(xPlayerDeathScript)
    ld [hli], a
    ld a, HIGH(xPlayerDeathScript)
    ld [hli], a
    ret

SECTION "Player Death Script", ROMX
; Scripted portion of death animation.
xPlayerDeathScript:
    pause
    set_pointer wScriptVars + 1, 0
.down
    set_pointer wScriptVars + 0, 0
    set_pointer wOctavia_Direction, DIR_DOWN
    set_pointer wPoppy_Direction, DIR_DOWN
    set_pointer wTiber_Direction, DIR_DOWN
    add_pointer wScriptVars + 1, 1
    branch wScriptVars + 1, DEATH_SPIN_COUNT, .fall
.downWait
    add_pointer wScriptVars + 0, 1
    branch wScriptVars + 0, DEATH_SPIN_SPEED * 1, .left
    jump .downWait

.left
    set_pointer wOctavia_Direction, DIR_LEFT
    set_pointer wPoppy_Direction, DIR_LEFT
    set_pointer wTiber_Direction, DIR_LEFT
.leftWait
    add_pointer wScriptVars + 0, 1
    branch wScriptVars + 0, DEATH_SPIN_SPEED * 2, .up
    jump .leftWait

.up
    set_pointer wOctavia_Direction, DIR_UP
    set_pointer wPoppy_Direction, DIR_UP
    set_pointer wTiber_Direction, DIR_UP
.upWait
    add_pointer wScriptVars + 0, 1
    branch wScriptVars + 0, DEATH_SPIN_SPEED * 3, .right
    jump .upWait

.right
    set_pointer wOctavia_Direction, DIR_RIGHT
    set_pointer wPoppy_Direction, DIR_RIGHT
    set_pointer wTiber_Direction, DIR_RIGHT
.rightWait
    add_pointer wScriptVars + 0, 1
    branch wScriptVars + 0, DEATH_SPIN_SPEED * 4, .down
    jump .rightWait
.fall
    call_function .fadeFully
    wait_fade
    call_function .startMenu
    end_script

.fadeFully
    ld a, $FF
    ld hl, wOCPDTarget
    ld c, sizeof_PALETTE * 8
    rst MemSetSmall
    ld a, PALETTE_STATE_FADE_LIGHT
    ld [wPaletteState], a
    ret

.startMenu
    ld a, ENGINE_STATE_MENU
    ldh [hEngineState], a
    ld de, xGameOverHeader
    ld b, BANK(xGameOverHeader)
    call AddMenu
    jp Main.end
