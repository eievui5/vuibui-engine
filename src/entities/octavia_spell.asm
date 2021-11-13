INCLUDE "banks.inc"
INCLUDE "entity.inc"
INCLUDE "hardware.inc"
INCLUDE "graphics.inc"
INCLUDE "tiledata.inc"

/*
    A generic spell entity. Copies its collision data onto the target,
    which allows multiple spells to share this entity.
*/

SECTION "Octavia Spell Definition", ROM0

OctaviaSpell::
    far_pointer OctaviaSpellLogic
    far_pointer OctaviaSpellMetasprites

SECTION "Octavia Spell", ROMX

OctaviaSpellLogic::
    ld hl, wOctaviaSpell_InvTimer
    inc [hl]
    ld hl, wOctaviaSpell_XVel
    ld a, [hld]
    ld c, a ; Store Xvel in c
    ld a, [hld]
    ld b, a ; Store Yvel in b
    ld a, [hl]
    add a, c ; Move X
    ld c, a
    ld [hld], a
    ld a, [hl]
    add a, b ; Move Y
    ld b, a
    ld [hl], a
    push bc
    call LookupMapData
    pop bc
    ld a, [hl]
    cp a, TILEDATA_BURNABLE
    jr z, .checkBurn
    cp a, TILEDATA_ENTITY_COLLISION - 1
    jr nc, .destroySelf
    ld a, [wOctaviaSpell_Flags]
    and a, a
    ld d, b
    ld e, c
    jr nz, .heal
    ld bc, 1 ; We don't want to ignore any entities, set to an invalid value.
    call DetectEntity
    and a, a
    ret z ; No? return...
    ld hl, wEntityArray + Entity_CollisionData
    add hl, bc
    ld d, h
    ld e, l
    ld a, [wOctaviaSpell_CollisionData] ; Load our collision data into the target
    ld [de], a

    push de
    ; Seek to both Entity_YPos
    ld hl, wOctaviaSpell_YPos
    ld a, Entity_YPos - Entity_CollisionData
    add a, e
    ld e, a
    ; Save our Position
    ld a, [hli] ; save Y
    ld l, [hl] ; store X
    ld h, a ; store Y
    ; Target Position
    ld a, [de]
    ld b, a ; save Y
    inc e
    ld a, [de]
    ld d, b ; store Y
    ld e, a ; store X
    call VectorFromHLToDE
    ; Lets load the knockback vector into the Target
    pop de
    ld a, Entity_YVel - Entity_CollisionData
    add a, e
    ld e, a
    ld a, h
    ld [de], a ; Load Y knockback
    inc e
    ld a, l
    ld [de], a ; Load X knockback

.destroySelf
    ld hl, wOctaviaSpell
    ld c, sizeof_Entity
    xor a, a
    rst MemSetSmall
    ld [wOctaviaSpellActive], a
    ret

.checkBurn
    ld a, [wOctaviaSpell_CollisionData]
    ASSERT DAMAGE_EFFECT_FIRE == 1 << 4
    bit 4, a
    jr z, .destroySelf

    ld [hl], TILEDATA_CLEAR

    ld de, -wMapData & $FFFF
    add hl, de
    ; Right now, the lowest 4 bits are the X position and the others are Y.
    ld a, l
    ld d, l
    and a, $F0
    ld l, a
    add hl, hl
    ld a, d
    and a, $0F
    ld e, a
    ld d, 0
    add hl, de
    add hl, hl

    ld de, _SCRN0
    add hl, de
    ld d, h
    ld e, l

    ; Finally, get the address of our target tile.
    ld a, [wDestroyedMapTile]
    ; Metatiles are 4 bytes.
    add a, a ; a * 2
    add a, a ; a * 4
    add a, LOW(wMetatileDefinitions)
    ld l, a
    adc a, HIGH(wMetatileDefinitions)
    sub a, l
    ld h, a

    call DrawMetatile
    jr .destroySelf

.heal
    call CheckAllyCollision
    inc a
    ret z ; If a == $FF, exit!
    ; Get target's max health.
    add a, LOW(wPlayerMaxHealth - 1)
    ld e, a
    adc a, HIGH(wPlayerMaxHealth - 1)
    sub a, e
    ld d, a
    ld a, [de]
    ld b, a ; save for compare
    ; Get the target's health field.
    ld a, Entity_Health - Entity_DataPointer
    add a, l
    ld l, a
    ; Increment target's health.
    ld a, [hl] ; TODO: This needs to check the player's max health
    cp a, b
    jr nc, .skipInc
    inc [hl]
.skipInc
    ld a, Entity_InvTimer - Entity_Health
    add a, l
    ld l, a
    ld a, 15 ; just a few frames!
    ld [hl], a
    jr .destroySelf


; The player dynamically loads their spell graphics.
OctaviaSpellMetasprites::
dw .red
dw .green
dw .blue
.red
    DB -8 ; y
    DB -8 ; x
    DB idof_vSpell ; Tile ID
    DB OAMF_PAL0 | OAMF_GBCPAL2 | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vSpell ; Tile ID
    DB OAMF_PAL0 | OAMF_GBCPAL2 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END
.green
    DB -8 ; y
    DB -8 ; x
    DB idof_vSpell ; Tile ID
    DB OAMF_PAL0 | OAMF_GBCPAL1 | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vSpell ; Tile ID
    DB OAMF_PAL0 | OAMF_GBCPAL1 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END
.blue
    DB -8 ; y
    DB -8 ; x
    DB idof_vSpell ; Tile ID
    DB OAMF_PAL0 | OAMF_GBCPAL0 | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vSpell ; Tile ID
    DB OAMF_PAL0 | OAMF_GBCPAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END