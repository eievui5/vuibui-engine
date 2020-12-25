INCLUDE "include/defines.inc"

SECTION "Entities", ROMX

Player::
.script
    dw PlayerScript
.end::

PlayerScript:
.move
    ldh a, [hInputBuffer]
.down
    inc de
    bit 7, a
    jr z, .right
    ld a, [de]
    add a, 1
    ld [de], a
    ldh a, [hInputBuffer]
.right
    inc de
    bit 4, a
    jr z, .render
    ld a, [de]
    add a, 1
    ld [de], a
    ldh a, [hInputBuffer]
.render
    ld hl, wShadowOAM
    ld bc, PlayerMetasprite
    ; Load Metasprite Y Offset
    ld a, [bc]
    ld [hl], a
    ; Load Y Location and add to offset
    ld a, [de]
    add a, [hl]
    ld [hli], a ; increment hl!
    ; Load Metasprite X Offset
    inc bc
    ld a, [bc]
    ld [hl], a
    ; Load X Location and add to offset
    inc de
    ld a, [de]
    add a, [hl]
    ld [hli], a
    ; Load active sprite graphic
    inc bc
    ld a, [bc]
    ld [hli], a
    ; Load attribute bits
    inc bc
    ld a, [bc]
    ld [hl], a
    ret

SECTION "Entity Array", WRAM0

wActiveEntityArray::
    ; Script Pointer
    ds 2 * MAXIMUM_ENTITIES
    ; Location Vector X
    ds 1 * MAXIMUM_ENTITIES
    ; Location Vector Y
    ds 1 * MAXIMUM_ENTITIES