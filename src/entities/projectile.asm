
INCLUDE "include/entities.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/graphics.inc"
include "include/tiles.inc"

SECTION "Projectile", ROMX 

ProjectileLogic::
    FindEntity Entity_InvTimer
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
    call LookupMapData
    pop bc
    ld a, [hl]
    cp a, TILE_COLLISION
    ret nz
    kill_entity
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