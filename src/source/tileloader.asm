
include "include/hardware.inc"
include "include/tiles.inc"
include "include/macros.inc"

SECTION "Tileloader", ROM0 

; Automatically loads the entire tilemap. Screen must be off.
; @ de: Destination ( _SCRN0, _SCRN1. VRAM Bank 1 for attributes. )
; @ hl: Metatiles definitions pointer
LoadMetatileMap:
    ld bc, $0000
.loop
    push de ; A lot of stack usage? This is the slow version, who cares.
    push hl
    push bc
    call LoadMetatile
    pop bc
    pop hl
    pop de

    inc b ; Next X pos
    ld a, b
    cp a, 16 ; Have we gone over?
    jr nz, .loop

    inc c ; Next Y pos
    ld a, c
    cp a, 16 ; Have we gone over?
    ret z
    ld b, $00 ; Reset X pos
    jr .loop

; Load the Entire map's data
LoadMapData:
    ld bc, $0000
.loop
    push bc
    call LoadMetatileData
    pop bc

    inc b ; Next X pos
    ld a, b
    cp a, 16 ; Have we gone over?
    jr nz, .loop

    inc c ; Next Y pos
    ld a, c
    cp a, 16 ; Have we gone over?
    ret z
    ld b, $00 ; Reset X pos
    jr .loop


; Loads a metatile from a given location on the current wMetatileMap, and places it accordingly.
; @ b:  Metatile X Location (0 - 15)
; @ c:  Metatile Y Location (0 - 15)
; @ de: Destination ( _SCRN0, _SCRN1, wMapData. VRAM Bank 1 for attributes. )
; @ hl: Metatiles definitions pointer
LoadMetatile::
    push hl

    ld a, b ; (0 - 16) -> (0 - 32)
    add a, a  ; a * 2
    add_r16_a d, e
    ld  h, c ; c * 256
    ld  l, $00 ; (0 - 16) -> (0 - 1024)
    srl h
    rr l ; c * 128
    srl h
    rr l ; c * 64
    add hl, de
    ld d, h
    ld e, l
    ; [de] is our map target

    ; Let's start by offsetting our map...
    ld hl, wMetatileMap
    ld a, b
    add_r16_a h, l ; add the X value
    ld a, c
    swap a ; c * 16
    add_r16_a h, l ; add the Y value
    ; [hl] contains our target tile.

    ; The use of a here is the only reason MAX_METATILES is currently 16.
    ; TODO: Sacrifice a bit of speed and use 16 bits.
    ld a, [hl] ; Load the tile
    ; Tiles are 4 bytes long.
    add a, a ; a * 2 !!!
    add a, a ; a * 4 !!!
    
    pop hl ; Definition target
    add_r16_a h, l ; Offset definition pointer
    ; [hl] is now the metatile data to copy.

    ld bc, $0202 ; loop counter: b = x, c = y
.loadRow
    ld a, [hli]
    ld [de], a
    inc de
    dec b ; Are we done with the row yet?
    jr nz, .loadRow
    dec c ; Are we done with the block yet?
    ret z
    ld b, $02 ; Neither? Next Row.
    ld a, 32 - 2
    add_r16_a d, e
    jr .loadRow


; Looks up a given metatile's data and copies it to wMapData
; @ b:  Metatile X Location (0 - 15)
; @ c:  Metatile Y Location (0 - 15)
LoadMetatileData::
    swap c ; c * 16
    ld d, $00
    ld e, b
    ld a, c
    add_r16_a d, e
    ld hl, wMetatileMap
    add hl, de
    ld a, [hl] ; Load the current tile
    ld hl, wMetatileData
    add_r16_a h, l
    ld a, [hl] ; Load that tile's data.
    ld hl, wMapData
    add hl, de
    ld [hl], a
    ret


SECTION "Metatile Definitions", WRAM0 
wMetatileDefinitions:
    ds 4 * MAX_METATILES
wMetatileAttributes:
    ds 4 * MAX_METATILES
wMetatileData:
    ds 4 * MAX_METATILES

SECTION "Tilemap", WRAM0
wMetatileMap:
    ds 16 * 16

SECTION "Map Data", WRAM0 ;Must be aligned to work with the fuction in place
wMapData: ; Like the tile map, but for data. Collision, pits, water.
    ds 16 * 16
