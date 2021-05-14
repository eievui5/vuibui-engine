
INCLUDE "include/entities.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/tiledata.inc"

MACRO find_arrow
    IF _NARG > 0
        ld hl, wPoppyArrow0 + \1
    ELSE
        ld hl, wPoppyArrow0
    ENDC 
    add hl, bc
ENDM

SECTION "Poppy Arrow", ROMX 

PoppyArrowLogic::
    find_arrow Entity_XVel
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
    dec a ; Ignore 0
    cp a, TILEDATA_ENTITY_WALL_MAX
    jr c, .destroySelf
    push bc
    ld bc, 1 ; We don't want to ignore any entities, set to an invalid value.
    call DetectEntity
    and a, a
    jr z, .popRet ; No? return...
    find_entity Entity_CollisionData
    ld d, h
    ld e, l
    pop bc
    find_arrow Entity_CollisionData
    ld a, [hl] ; Load our collision data into the target
    ld [de], a
    push de
    ; Seek to both Entity_YPos
    find_arrow Entity_YPos
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
    call CalculateKnockback
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
    find_arrow
    ld c, sizeof_Entity
    xor a, a
    rst memset_small
    ld hl, wPoppyActiveArrows
    dec [hl]
    ret

.popRet
    pop bc
    ret

ArrowMetasprites::
    dw .down
    dw .up
    dw .right
    dw .left
    .down
        db -8 ; y
        db -4 ; x
        db TILE_ARROW_DOWN ; Tile ID
        db OAMF_PAL0 | OAMF_BANK0 | OAMF_YFLIP ; Flags
        
        db METASPRITE_END
    .up
        db -8 ; y
        db -4 ; x
        db TILE_ARROW_DOWN ; Tile ID
        db OAMF_PAL0 | OAMF_BANK0 ; Flags

        db METASPRITE_END
    .right
        db -8 ; y
        db -8 ; x
        db TILE_ARROW_RIGHT_FLETCH; Tile ID
        db OAMF_PAL0 | OAMF_BANK0 ; Flags

        db -8 ; y
        db 0 ; x
        db TILE_ARROW_RIGHT_POINT; Tile ID
        db OAMF_PAL0 | OAMF_BANK0 ; Flags

        db METASPRITE_END
    .left
        db -8 ; y
        db -8 ; x
        db TILE_ARROW_RIGHT_POINT; Tile ID
        db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

        db -8 ; y
        db 0 ; x
        db TILE_ARROW_RIGHT_FLETCH; Tile ID
        db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

        db METASPRITE_END