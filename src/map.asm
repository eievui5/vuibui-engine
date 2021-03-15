
include "include/map.inc"
include "include/macros.inc"

; Keep these all in the same bank.
SECTION "Map Lookup", ROM0

UpdateActiveMap::
    call GetActiveMap
    push bc ; Save the data pointer
    ; Copy the map
    ld bc, MAP_SIZE
    ld de, wMetatileMap
    call memcopy
    ; Evaluate map data
    pop hl
.nextData
    ld a, [hli]
    and a, a
    ret z
    ASSERT MAPDATA_ENTITY == 1
    dec a
    jr z, .mapdataEntity 
    ret
.mapdataEntity
    ; Entity pointers are stored as little-endian, but they're expected to be big.
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a
    push hl
    call SpawnEntity
    pop hl
    jr .nextData

; Returns the active Map in `hl`, and its data in `bc`
; Used to copy map into wMetatileMap and spawn entities/run scripts
GetActiveMap::
    ld a, [wActiveWorldMap]
    ld b, a
    add a, b ; a * 2
    add a, b ; a * 3
    ld hl, MapLookup
    add_r16_a h, l

    ld a, [hli] ; Load target bank. Unused.
    ; Switch banks here.
    ld a, [hli] ; Load first pointer byte
    ld b, a
    ld h, [hl] ; Load second pointer byte
    ld l, b ; hl is now the map pointer

    ld a, [hli] ; Load and skip the width byte.
    ld c, a
    ld a, [hli] ; Load and skip the size byte
    ld d, a
    ld a, [wWorldMapPositionX]
    add a, a ; Pointers are 2 bytes long.
    add_r16_a h, l ; Add X offset.
    ld a, [wWorldMapPositionY]
    and a, a ; If y = 0 just skip.
    jr z, .skipY
    ld b, a 
    ld a, c 
.multLoop ; Multiply c (width) * b (ypos) and add the result to hl
    add_r16_a h, l
    dec b
    jr nz, .multLoop
.skipY ; This is dumb

    ld b, h
    ld c, l
    ld a, d ; Restore map size
    add_r16_a b, c ; Offset to find the map data
    ld a, [bc] ; Load first pointer byte
    ld d, a
    inc bc
    ld a, [bc] ; Load second pointer byte
    ld c, d
    ld b, a ; bc is now the map data pointer

    ld a, [hli] ; Load first pointer byte
    ld h, [hl] ; Load second pointer byte
    ld l, a ; hl is now the map pointer
    ; hl now points to the correct map.
    ; bc is the map's data.
    ret 

; Used to check which World Map we're referencing (Overworld, Dungeon, etc...)
; Maximum of 85 Maps, since 85 * 3 = 255
MapLookup:
    ; World Map 0
    far_pointer OverworldMap

; ### World Maps ###

; Keep associated maps within the same bank
; Precede map with a width byte. db (width) * 2. Max width == 128
; and a size byte. db (width * height) * 2.

SECTION "Overworld Map", ROMX

OverworldMap:
    db (2) * 2      ; Width
    db (2 * 2) * 2  ; Size
    dw DebugMap, DebugMap2
    dw DebugMap2, DebugMap
.data
    dw DebugMap.data, DebugMap2.data
    dw DebugMap2.data, DebugMap.data

DebugMap: ; Using DebugMetatiles
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $01, $01, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01
    db $01, $00, $01, $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
.data
    ; Create entities for stress-testing!
    FOR i, 3
        create_entity HitDummy, 128, i * 16 + 64
    ENDR
    FOR i, 3
        create_entity HitDummy, 128 + 16, i * 16 + 64
    ENDR
    FOR i, 3
        create_entity HitDummy, 128 + 32, i * 16 + 64
    ENDR
    end_mapdata

DebugMap2: ; Using DebugMetatiles
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
.data:
    end_mapdata

SECTION "Active Map Variables", WRAM0

; Which map are we on?
wActiveWorldMap:: 
    ds 1

; Which room are we in?
wWorldMapPositionX:: 
    ds 1

wWorldMapPositionY:: 
    ds 1
    