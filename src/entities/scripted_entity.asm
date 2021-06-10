INCLUDE "include/banks.inc"
INCLUDE "include/directions.inc"
INCLUDE "include/entity.inc"
INCLUDE "include/entity_script.inc"

SECTION "Scripted Entity Definition", ROM0

ScriptedEntity::
    far_pointer ScriptedEntityLogic
    far_pointer TiberMetasprites
    far_pointer RenderMetaspriteDirection.native

SECTION "Scripted Entity Logic", ROMX

ScriptedEntityLogic:
    ld hl, wEntityFieldArray
    add hl, bc
    ld a, [hli]
    ld d, [hl]
    or a, d
    jr nz, .skipInit
        ld a, HIGH(ScriptedEntityScript)
        ld [hld], a
        ld [hl], LOW(ScriptedEntityScript)
.skipInit
    jp HandleEntityScript

ScriptedEntityScript:
    ; seta - Load a value into a given field
    seta Entity_Direction, DIR_DOWN
    ; yield - Return and wait for the next frame.
    yield
    seta Entity_Direction, DIR_RIGHT
    yield
    seta Entity_Direction, DIR_UP
    yield
    seta Entity_Direction, DIR_LEFT
    yield
    ; jump - Sets the script pointer to a given address
    jump ScriptedEntityScript