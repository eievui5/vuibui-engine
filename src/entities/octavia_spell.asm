
INCLUDE "include/enum.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/graphics.inc"
include "include/tiles.inc"

/* 
    A generic spell entity. Copies its collision data onto the target, 
    which allows multiple spells to share this entity.
*/

SECTION "Octavia Spell", ROMX 

OctaviaSpellLogic::
    ld hl, wOctaviaSpell_InvTimer
    inc [hl]
    ld hl, wOctaviaSpell_XVel
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
    cp a, TILE_ENTITY_WALL_MAX
    jr c, .destroySelf
    push bc
    call DetectEntity
    inc c ; Did we find something?
    jr z, .popReturn ; No? return...
    dec c
    find_entity Entity_CollisionData
    ld d, h
    ld e, l
    pop bc
    ld a, [wOctaviaSpell_CollisionData] ; Load our collision data into the target
    ld [de], a
    push bc

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
    ld hl, wOctaviaSpell
    ld bc, sizeof_Entity
    xor a, a
    call memset
    ld [wOctaviaSpellActive], a
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
    db TILE_PLAYER_SPELL ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_PLAYER_SPELL ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END