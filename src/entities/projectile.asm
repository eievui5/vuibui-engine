
INCLUDE "include/enum.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/graphics.inc"
include "include/tiles.inc"

SECTION "Projectile", ROMX 

ProjectileLogic::
    find_entity Entity_InvTimer
    ld a, [hl]
    inc a
    ld [hl], a
    ld a, Entity_XVel - Entity_InvTimer
    add a, l
    ld l, a
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
    cp a, TILE_COLLISION
    jr z, .destroySelf
    push bc
    call DetectEntity
    inc c ; Did we find something?
    jr z, .popReturn ; No? return...
    dec c
    find_entity Entity_CollisionData
    ld d, h
    ld e, l
    pop bc
    find_entity Entity_CollisionData
    ld a, $01 ; Load our collision data into the target
    ld [de], a
    push bc

    push de
    ; Seek to both Entity_YPos
    ld a, Entity_YPos - Entity_CollisionData 
    add a, l
    ld l, a
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

    pop bc
.destroySelf
    kill_entity
    ret
.popReturn
    pop bc
    ret

; The player dynamically loads their spell graphics.
OctaviaSpellMetasprites::
dw .sprite
.sprite
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMB_XFLIP ; Flags

    db METASPRITE_END

    db METASPRITE_END