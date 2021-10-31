INCLUDE "banks.inc"
INCLUDE "directions.inc"
INCLUDE "entity.inc"
INCLUDE "entity_script.inc"
INCLUDE "graphics.inc"
INCLUDE "hardware.inc"

DEF GRAPHICS_OFFSET EQU $9C
DEF STARTING_HEALTH EQU 2

SECTION "Beach Crab Definition", ROM0

BeachCrab::
    far_pointer BeachCrabLogic
    far_pointer CrabMetasprites
    far_pointer RenderMetasprite.native

SECTION "Beach Crab Logic", ROMX

BeachCrabScript:

    define_fields
    field DAMAGE_ENABLE
    field COUNTER
    field ANIM
    field HIT_WALL

    new_script

    ; Enable the entity to take damage.
    setf DAMAGE_ENABLE, 1
    seta Entity_Health, STARTING_HEALTH
    seta Entity_Frame, 0

.chase
    randa Entity_Direction, %11
    ; Wait some frames before moving.
    randf COUNTER, %100100
    forf COUNTER
        target_dir
        attack_player 2
        animate ANIM, %1000, FRAME_LEFT, FRAME_RIGHT
        checked_movef HIT_WALL
        if_nzf HIT_WALL
            jump .chase
        endif
        yield
        attack_player 1
        yield
    endfor
    randf COUNTER, %1001000
    seta Entity_Frame, FRAME_NORMAL
    forf COUNTER
        animate ANIM, %10000000, FRAME_NORMAL, FRAME_BOTH
        attack_player 1
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

BeachCrabLogic:
    ; Check the Field array to see if we've initialized.
    ld h, HIGH(wEntityFieldArray)
    ld l, c
    ld a, [hli]
    ld d, [hl]
    or a, d
    jr nz, .skipInit
        ; Set Script
        ld [hl], HIGH(BeachCrabScript)
		dec l
        ld [hl], LOW(BeachCrabScript)
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
        ld a, LOW(BeachCrabScript.damage)
        ld [hli], a
        ld [hl], HIGH(BeachCrabScript.damage)
.noDamage
    ld h, HIGH(wEntityArray)
    ld a, Entity_CollisionData
    add a, c
    ld l, a
    xor a, a
    ld [hl], a ; Clear old damage.
    ; Run the script thread
    jp HandleEntityScript

CrabMetasprites:
    DEF FRAME_NORMAL EQU 0
    DW .normal
    DEF FRAME_LEFT EQU 1
    DW .left
    DEF FRAME_RIGHT EQU 2
    DW .right
    DEF FRAME_BOTH EQU 3
    DW .both

.normal
    DB -8, -8, GRAPHICS_OFFSET, 0
    DB -8, 0, GRAPHICS_OFFSET + 2, 0
    DB METASPRITE_END

.left
    DB -8, -8, GRAPHICS_OFFSET + 4, 0
    DB -8, 0, GRAPHICS_OFFSET + 2, 0
    DB METASPRITE_END

.right
    DB -8, -8, GRAPHICS_OFFSET, 0
    DB -8, 0, GRAPHICS_OFFSET + 6, 0
    DB METASPRITE_END

.both
    DB -8, -8, GRAPHICS_OFFSET + 4, 0
    DB -8, 0, GRAPHICS_OFFSET + 6, 0
    DB METASPRITE_END