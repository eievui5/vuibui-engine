
include "include/hardware.inc"
include "include/tiles.inc"
include "include/macros.inc"

SECTION "Tileloader", ROM0 

; TODO: Make this load based on coordinates, so that scrolling works.
; @ de: Destination ( _SCRN0, _SCRN1, wMapData. VRAM Bank 1 for attributes. )
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
    cp a, $08 ; Have we gone over?
    jr nz, .loop

    inc c ; Next Y pos
    ld a, c
    cp a, $08 ; Have we gone over?
    ret z
    ld b, $00 ; Reset X pos
    jr .loop


; Loads a metatile from a given location on the current wMetatileMap, and places it accordingly.
; @ b:  Metatile X Location ($00 - $08)
; @ c:  Metatile Y Location ($00 - $08)
; @ de: Destination ( _SCRN0, _SCRN1, wMapData. VRAM Bank 1 for attributes. )
; @ hl: Metatiles definitions pointer
LoadMetatile::
    push hl

    ld a, b ; (0 - 8) -> (0 - 32)
    add a, a  ; a * 2
    add a, a ; a * 4 
    add_r16_a d, e
    ld  h, c
    ld  l, $00
    srl h
    rr l ; HL * 128
    add hl, de
    ld d, h
    ld e, l
    ; [de] is our map target

    ; Let's start by offsetting our map...
    ld hl, wMetatileMap
    ld a, b
    add_r16_a h, l ; add the X value
    ld a, c
    add a, a ; a * 2
    add a, a ; a * 4
    add a, a ; a * 8 !!!
    add_r16_a h, l ; add the Y value
    ; [hl] contains our target tile.

    ; The use of a here is the only reason MAX_METATILES is currently 16.
    ; TODO: Sacrifice a bit of speed and use 16 bits.
    ld a, [hl] ; Load the tile
    swap a ; a * 16
    
    pop hl ; Definition target
    add_r16_a h, l ; Offset definition pointer
    ; [hl] is now the metatile data to copy.

    ld bc, $0404 ; loop counter: b = x, c = y
.loadRow
    ld a, [hli]
    ld [de], a
    inc de
    dec b ; Are we done with the row yet?
    jr nz, .loadRow
    dec c ; Are we done with the block yet?
    ret z
    ld b, $04 ; Neither? Next Row.
    ld a, 32 - 4
    add_r16_a d, e
    jr .loadRow



SECTION "Metatile Definitions", WRAM0 
wMetatileDefinitions:
    ds 16 * MAX_METATILES
wMetatileAttributes:
    ds 16 * MAX_METATILES
wMetatileData:
    ds 16 * MAX_METATILES

SECTION "Tilemap", WRAM0
wMetatileMap:
    ds 8 * 8

SECTION "Map Data", WRAM0 ;Must be aligned to work with the fuction in place
wMapData: ; Like the tile map, but for data. Collision, pits, water.
    ds 32 * 32
