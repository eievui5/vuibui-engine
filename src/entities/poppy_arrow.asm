INCLUDE "banks.inc"
INCLUDE "entity.inc"
INCLUDE "hardware.inc"
INCLUDE "graphics.inc"
INCLUDE "tiledata.inc"

SECTION "Poppy Arrow Definition", ROM0

PoppyArrow::
    far_pointer PoppyArrowLogic
    far_pointer ArrowMetasprites

SECTION "Poppy Arrow", ROMX

PoppyArrowLogic::
    ld hl, wPoppyArrow0 + Entity_XVel
    add hl, bc
    ld a, [hld]
    ld e, a ; Store Xvel in e
    ld a, [hld]
    ld d, a ; Store Yvel in d
    ld a, [hl]
    add a, e ; Move X
    ld e, a
    ld [hld], a
    ld a, [hl]
    add a, d ; Move Y
    ld d, a
    ld [hl], a
    push bc
    ld b, d
    ld c, e
    push de
    call LookupMapData
    pop de
    pop bc
    ld a, [hl]
    cp a, TILEDATA_ENTITY_COLLISION - 1
    jr nc, .destroySelf
    push bc
    ld bc, 1 ; We don't want to ignore any entities, set to an invalid value.
    call DetectEntity
    and a, a
    jr z, .popRet ; No? return...
    ld hl, wEntityArray + Entity_CollisionData
    add hl, bc
    ld d, h
    ld e, l
    pop bc
    ld hl, wPoppyArrow0 + Entity_CollisionData
    add hl, bc
    ld a, [hl] ; Load our collision data into the target
    ld [de], a
    push de
    ; Seek to both Entity_YPos
    ld hl, wPoppyArrow0 + Entity_YPos
    add hl, bc
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
    ld b, $00 ; Fix B (upper byte will always be 0 for the arrows.)
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
    ld hl, wPoppyArrow0
    add hl, bc
    ld c, sizeof_Entity
    xor a, a
    rst MemSetSmall
    ld hl, wPoppyActiveArrows
    dec [hl]
    ret

.popRet
    pop bc
    ret

ArrowMetasprites::
    DW .down
    DW .up
    DW .right
    DW .left
    .down
        DB -8 ; y
        DB -4 ; x
        DB TILE_ARROW_DOWN ; Tile ID
        DB OAMF_PAL0 | OAMF_BANK0 | OAMF_YFLIP ; Flags

        DB METASPRITE_END
    .up
        DB -8 ; y
        DB -4 ; x
        DB TILE_ARROW_DOWN ; Tile ID
        DB OAMF_PAL0 | OAMF_BANK0 ; Flags

        DB METASPRITE_END
    .right
        DB -8 ; y
        DB -8 ; x
        DB TILE_ARROW_RIGHT_FLETCH; Tile ID
        DB OAMF_PAL0 | OAMF_BANK0 ; Flags

        DB -8 ; y
        DB 0 ; x
        DB TILE_ARROW_RIGHT_POINT; Tile ID
        DB OAMF_PAL0 | OAMF_BANK0 ; Flags

        DB METASPRITE_END
    .left
        DB -8 ; y
        DB -8 ; x
        DB TILE_ARROW_RIGHT_POINT; Tile ID
        DB OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

        DB -8 ; y
        DB 0 ; x
        DB TILE_ARROW_RIGHT_FLETCH; Tile ID
        DB OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

        DB METASPRITE_END