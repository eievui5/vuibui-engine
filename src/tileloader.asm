include "include/hardware.inc"
include "include/tiles.inc"
include "include/macros.inc"

SECTION "Tileloader", ROM0 

LoadMetatileMap::
    ld bc, DebugMetatiles.end - DebugMetatiles
    ld hl, DebugMetatiles
    ld de, wMetatileDefinitions ; Metatiles must be defined
    call MemCopy

    ld bc, DebugTilemap ; Input for now, may be loaded later.
; Real Start
    ld hl, _SCRN0
    push hl ; We need to save the current location on screen
.metatileLoop
    ld de, wMetatileDefinitions
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
    ret z ; Return if so.
    push hl
    jr .metatileLoop