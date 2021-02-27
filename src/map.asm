
include "include/map.inc"
include "include/macros.inc"

; Keep these all in the same bank.
SECTION "Map Lookup", ROM0

; Returns the active Map (Not World Map) in HL. Destroys a, bc, hl
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
    ld a, [hl] ; Load second pointer byte
    ld h, a
    ld l, b ; hl is now the map pointer

    ld a, [hli] ; Load and skip the width byte.
    ld c, a
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

    ; If someone can figure out why this is backwards... you're at this better than me.
    ld a, [hli] ; Load first pointer byte
    ld b, a
    ld a, [hl] ; Load second pointer byte
    ld h, a
    ld l, b ; hl is now the map pointer


    ret ; hl now points to the correct map.

; Used to check which World Map we're referencing (Overworld, Dungeon, etc...)
; Maximum of 85 Maps, since 85 * 3 = 255
MapLookup::
    ; World Map 0
    far_pointer OverworldMap

; ### World Maps ###

; Keep associated maps within the same bank
; Precede map with a width byte. db (width) * 2. Max width == 128

SECTION "Overworld Map", ROMX

OverworldMap:
    db (2) * 2 ; Width
    dw DebugMap, DebugMap2
    dw DebugMap2, DebugMap


DebugMap: ; Using DebugMetatiles
    db $03, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $03
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    db $00, $01, $01, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01
    db $02, $00, $01, $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
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
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $03

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

SECTION "Active Map Variables", WRAM0

; Which map are we on?
wActiveWorldMap:: 
    ds 1

; Which room are we in?
wWorldMapPositionX:: 
    ds 1

wWorldMapPositionY:: 
    ds 1
    