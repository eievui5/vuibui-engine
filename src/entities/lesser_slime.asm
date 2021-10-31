INCLUDE "banks.inc"
INCLUDE "directions.inc"
INCLUDE "entity.inc"
INCLUDE "entity_script.inc"
INCLUDE "graphics.inc"
INCLUDE "hardware.inc"

DEF GRAPHICS_OFFSET EQU $84
DEF STARTING_HEALTH EQU 4

SECTION "Lesser Slime Definition", ROM0

LesserSlime::
    far_pointer LesserSlimeLogic
    far_pointer SlimeMetasprites
    far_pointer RenderMetaspriteDirection.native

SECTION "Lesser Slime Logic", ROMX

    define_fields
    field DAMAGE_ENABLE
    field COUNTER
    field ANIM

LesserSlimeLogic:
    ; Check the Field array to see if we've initialized.
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld d, [hl]
    or a, d
    jr nz, .skipInit
        ; Set Script
        ld a, HIGH(LesserSlimeScript)
        ld [hld], a
        ld [hl], LOW(LesserSlimeScript)
        inc l
.skipInit
    ASSERT DAMAGE_ENABLE == 0
    inc l
    ld a, [hl]
    and a, a
    jr z, .noDamage
    ; Check for damage.
    ld h, HIGH(wEntityArray)
    ld a, Entity_CollisionData
    add a, c
    ld l, a
    ASSERT Entity_CollisionData + 1 == Entity_Health
    ld a, [hli]
    and a, a
    jr z, .noDamage ; No damage? Return.
        and a, DAMAGE_MASK ; Ignore damage effects
        ld d, a
        ld a, [hl]
        sub a, d
        ASSERT Entity_CollisionData + 1 == Entity_Health
        ld [hld], a
        ld h, HIGH(wEntityFieldArray)
        ld l, c
        ld a, LOW(LesserSlimeScript.damage)
        ld [hli], a
        ld [hl], HIGH(LesserSlimeScript.damage)
.noDamage
    ld h, HIGH(wEntityArray)
    ld a, Entity_CollisionData
    add a, c
    ld l, a
    xor a, a
    ld [hl], a ; Clear old damage.
    ; Run the script thread
    jp HandleEntityScript

LesserSlimeScript:
    new_script

    ; Enable the entity to take damage.
    setf DAMAGE_ENABLE, 1
    seta Entity_Health, STARTING_HEALTH

.chase
    ; Wait some frames before moving.
    randf COUNTER, %100001
    forf COUNTER
        animate ANIM, %10000, FRAME_NORMAL, FRAME_BOUNCE
        yield
    endfor
    ; Move for a few frames.
    randf COUNTER, %11
    forf COUNTER
        animate ANIM, %1000, FRAME_NORMAL, FRAME_BOUNCE
        chase_player
        attack_player 2
        yield
    endfor
    ; Loop.
    jump .chase

.damage
    ; Get knocked back for 60 frames
    setf DAMAGE_ENABLE, 0 ; Disable damage during knockback.
    seta Entity_InvTimer, 12 ; Use InvTimer for automatic animation!
    fora Entity_InvTimer
        move ; Enemies set velocity to the knockback direction, so just move!
        yield
    endfor
    setf DAMAGE_ENABLE, 1 ; Re-enable damage when done.
    seta Entity_InvTimer, 0
    if_nega Entity_Health
        death_particles
    endif
    jump .chase ; Go back to chase when you're done.

    end_script

SlimeMetasprites:
    DEF FRAME_NORMAL EQU 0
    ; Normal sprite
    DW .normal
    DW .flip
    DW .normal
    DW .flip
    DEF FRAME_BOUNCE EQU 4
    ; Smaller, "squished" sprite
    DW .bounce
    DW .bounceFlip
    DW .bounce
    DW .bounceFlip

.normal
    DB -8, -8, GRAPHICS_OFFSET + 2, OAMF_XFLIP
    DB -8, 0, GRAPHICS_OFFSET, OAMF_XFLIP
    DB METASPRITE_END
.bounce
    DB -8, -8, GRAPHICS_OFFSET + 6, OAMF_XFLIP
    DB -8, 0, GRAPHICS_OFFSET + 4, OAMF_XFLIP
    DB METASPRITE_END
.flip
    DB -8, -8, GRAPHICS_OFFSET, 0
    DB -8, 0, GRAPHICS_OFFSET + 2, 0
    DB METASPRITE_END
.bounceFlip
    DB -8, -8, GRAPHICS_OFFSET + 4, 0
    DB -8, 0, GRAPHICS_OFFSET + 6, 0
    DB METASPRITE_END
