include "include/hardware.inc"
include "include/tiles.inc"
include "include/macros.inc"

SECTION "Tileloader", ROM0 

; TODO: Make this load based on coordinates, so that scrolling works.
; @ args:
; @ bc: Tilemap to load from
; @ de: Data to reference (defs, atrbs, data)
; @ hl: destination (_SCRN0, _SCRN1, Collision Map)
LoadMetatileMap::
    push de
    push hl ; We need to save the current location on screen
.metatileLoop
    pop hl ; Complex way of preserving de
    pop de ; I hate this function and will change everything later
    push de
    push hl
    ld a, [bc] ; Load tile offset
    inc bc
    ld h, 0 
    ld l, a
    mult_hl_16
    add hl, de ; Offset the definitions to find the tile.
    ld d, h
    ld e, l
    pop hl ; Restore screen Location
    push bc ; Save Tilemap
    ld bc, $0404 ; loop counters
.tileRowLoop
    ld a, [de] 
    inc de
    ld [hli], a
    dec b
    jr nz, .tileRowLoop ; Loop if not 0
    ; Configure Next Row
    ld b, $04
    ld a, $1C
    add_hl_a ; Offset to the next row
    dec c
    jr nz, .tileRowLoop ; Loop if not 0
    ; If we must start a new Row, both of these will fail
    ld a, l
    cp a, $1C
    jr z, .nextMetaRow
    cp a, $9C
    jr z, .nextMetaRow
.nextMetaColumn
    ; sub hl, $007C
    ld a, l
    sub a, $7C
    ld l, a
    ld a, h
    sbc a, $00
    ld h, a
    jr .nextMetaTile
.nextMetaRow
    ; sub hl, $001C
    ld a, l
    sub a, $1C
    ld l, a
    ld a, h
    sbc a, $00
    ld h, a
.nextMetaTile
    pop bc ; Remember the tilemap?
    ld a, $9C ; Check if we've left the screen
    cp a, h
    jr z, .return ; Return if so.
    push hl
    jr .metatileLoop
.return
    pop de
    ret


; Loads a metatile from a given location on the current wMetatileMap, and places it accordingly.
; @ 0:  wMetatileDefinitions -> _SCRN0
; @ 1:  wMetatileAttributes  -> _SCRN0 (Bank1)
; @ 2:  wMetatileData        -> wMapData
; @ b: Metatile X Location ($00 - $08)
; @ c: Metatile Y Location ($00 - $08)
LoadMetatile::
    ; Placeholders, these should become args.
    ld hl, wMetatileMap
    ld e, $00 ; E for enumeration :)

    ld a, b
    add_r16_a h, l ; add the X value
    ld c, a
    add a, a ; a * 2
    add a, a ; a * 4
    add a, a ; a * 8 !!!
    add_r16_a h, l ; add the Y value
    ld a, [hl] ; `a` has our tile! 



SECTION "Metatile Definitions", WRAM0 
wMetatileDefinitions::
    ds 16 * MAX_METATILES
wMetatileAttributes::
    ds 16 * MAX_METATILES
wMetatileData::
    ds 16 * MAX_METATILES

SECTION "Tilemap", WRAM0
wMetatileMap::
    ds 8 * 8

SECTION "Map Data", WRAM0 ;Must be aligned to work with the fuction in place
wMapData:: ; Like the tile map, but for data. Collision, pits, water.
    ds 32 * 32