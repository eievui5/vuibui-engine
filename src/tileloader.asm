
INCLUDE "include/directions.inc"
include "include/engine.inc"
include "include/hardware.inc"
INCLUDE "include/tiledata.inc"
include "include/macros.inc"

SECTION "Tileloader", ROM0 

; Automatically loads the entire tilemap. Screen must be off.
; @ de: Destination ( _SCRN0, _SCRN1. VRAM Bank 1 for attributes. )
; @ hl: Metatiles definitions pointer
LoadMetatileMap::
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
LoadMapData::
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

; 4 is possible on the DMG, but I think it's cutting it close.
; Try setting this to 3 if you have issues. (May require recalibrating scrolling)
TILES_PER_FRAME EQU 4

; Scrolls the screen and loads tiles during VBlank. Also handles tilemap updates
; when the screen is hidden, with disabled scrolling.
VBlankScrollLoader::
    ld a, [wRoomTransitionDirection]
    and a, a
    ret z

    ; Load a metatile if needed
    ld a, [wVBlankMapLoadPosition]
    ld b, a
    ld b, TILES_PER_FRAME ; Save the index up here so that we can push in the loop
    and a, a
    jr nz, .skipFirst
    ; If this is our first pass, tell the Main loop to pause and load tile data.
    ld a, ENGINE_STATE_ROOM_TRANSITION
    ldh [hEngineState], a

    ld a, [wRoomTransitionDirection]
    ; Up and left must not load the 0 tile until the end.
    cp a, TRANSDIR_UP
    jr z, .skipFirst
    cp a, TRANSDIR_LEFT
    jr z, .skipFirst
    ld bc, $0000
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatile
    ld a, [hSystem]
    and a, a
    jr z, :+
    ; If not on DMG, load attributes
    ld a, 1 ; Swap banks
    ldh [rVBK], a
    ld bc, $0000
    ld de, _SCRN0
    ld hl, wMetatileAttributes
    call LoadMetatile
    xor a, a ; Return to bank 0
    ldh [rVBK], a
:
    ld b, TILES_PER_FRAME - 1 ; Keep track of the extra tile so that we're not overloaded.
.skipFirst
    push bc ; Save that index...
    ld a, [wVBlankMapLoadPosition]
    ld b, a
    ld a, [wRoomTransitionDirection]

    ASSERT TRANSDIR_DOWN == 1
    dec a
    jr z, .loadDown
    ASSERT TRANSDIR_UP == 2
    dec a
    jr z, .loadUp
    ASSERT TRANSDIR_RIGHT == 3
    ; Left and Right both need b swapped
    swap b
    dec a
    jr z, .loadRight
    ASSERT (TRANSDIR_LEFT == 4) && (TRANSDIR_NONE == 5) ; No direction re-uses LEFT
    ; Logic pertaining to each direction
    ; If carry is set, stop loading.
.loadLeft
    dec b
    jr z, .endLoad
    jr .horzontalLoadTile
.loadRight
    inc b
    jr z, .endLoad
    jr .horzontalLoadTile
.loadUp
    dec b
    jr z, .endLoad
    jr .loadTile
.loadDown
    inc b
    jr z, .endLoad
    jr .loadTile

.endLoad
    xor a
    ld [wRoomTransitionDirection], a
    ld [wVBlankMapLoadPosition], a
    ; The 0 tile still needs to be loaded.
    ; Don't worry about overwriting it if it's already there.
    ld bc, $0000
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatile    
    ldh a, [hSystem]
    and a, a
    jr z, :+
    ; If not on DMG, load attributes
    ld a, 1 ; Swap banks
    ldh [rVBK], a
    ld bc, $0000
    ld de, _SCRN0
    ld hl, wMetatileAttributes
    call LoadMetatile
    xor a, a ; Return to bank 0
    ldh [rVBK], a
:  

    xor a, a
    ldh [hEngineState], a ; Reset engine
    ld a, PALETTE_STATE_RESET
    ld [wPaletteState], a
    pop bc ; Clean stack
    ret

.horzontalLoadTile
    swap b ; We can save a single `swap` by doing this.
.loadTile
    ; Set up XY destination
    ; Mask out and load Y
    ld a, b
    ld [wVBlankMapLoadPosition], a
    and a, %11110000
    swap a
    ld c, a
    ; Mask out and load X
    ld a, b
    and a, %00001111
    ld b, a

    ; Load tiles onto _SCRN0 from the wMetatileDefinitions.
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    push bc
    call LoadMetatile
    pop bc
    ldh a, [hSystem]
    and a, a
    jr z, :+
    ; If not on DMG, load attributes
    ld a, 1 ; Swap banks
    ldh [rVBK], a
    ld de, _SCRN0
    ld hl, wMetatileAttributes
    call LoadMetatile
    xor a, a ; Return to bank 0
    ldh [rVBK], a
:

    ; We can load more than one tile, so lets see how many are left.
    pop bc ; Remember the tile index? 
    dec b
    jp nz, .skipFirst ; Still more? Keep going!
    ld a, [wVBlankMapLoadPosition]
    ; Only move the player/screen after the first row is done.
    and a, %11110000
    ret z
    cp a, $F0 
    ret z

    ; Scrolling logic, then fall through ↓
    ld a, [wRoomTransitionDirection]
    ASSERT TRANSDIR_DOWN == 1
    dec a
    jr z, .scrollDown
    ASSERT TRANSDIR_UP == 2
    dec a
    jr z, .scrollUp
    ASSERT TRANSDIR_RIGHT == 3
    dec a
    jr z, .scrollRight
    ASSERT TRANSDIR_LEFT == 4
    dec a
    jr z, .scrollLeft
    ASSERT TRANSDIR_NONE == 5
    ret

.scrollDown
    ldh a, [hSCYBuffer]
    and a, a
    ret z
    inc a
    jr z, .storeY
    inc a
    jr z, .storeY
    inc a
    jr .storeY
.scrollUp
    ldh a, [hSCYBuffer]
    sub a, 256 - 144 + 16 ; This might be dumb.
    ret z
    dec a
    jr z, .storeDown
    dec a
    jr z, .storeDown
    dec a
.storeDown
    add a, 256 - 144 + 16 ; Fix offset
.storeY
    ldh [hSCYBuffer], a
    ret
.scrollRight
    ldh a, [hSCXBuffer]
    and a, a
    ret z
    inc a
    jr z, .storeX
    inc a
    jr z, .storeX
    inc a
    jr z, .storeX ; Screen is wider, we need an extra step
    inc a
    jr .storeX
.scrollLeft
    ldh a, [hSCXBuffer]
    sub a, 256 - 160 ; This might be dumb.
    ret z
    dec a
    jr z, .storeLeft
    dec a
    jr z, .storeLeft
    dec a
    jr z, .storeLeft
    dec a
.storeLeft
    add a, 256 - 160 ; Fix offset
.storeX
    ldh [hSCXBuffer], a
    ret

; Used to load a full map of 20*14 regular tiles
; @ hl: Pointer to upper-left tile
; @ de: Pointer to source tile map
; @ b : Rows to copy
ScreenCopy::
    ld c, SCRN_X_B
.rowLoop
    ld a, [de]
    ld [hli], a
    inc de
    dec c
    jr nz, .rowLoop
    dec b
    ret z
    ld a, SCRN_VX_B - SCRN_X_B
    add_r16_a hl
    jr ScreenCopy

SECTION "Metatile Definitions", WRAM0 
wMetatileDefinitions::
    ; 2 * 2 Tiles
    ds 4 * MAX_METATILES
wMetatileAttributes::
    ; 2 * 2 Attributes
    ds 4 * MAX_METATILES
wMetatileData::
    ; 1 data byte per tile.
    ds MAX_METATILES

SECTION "Tilemap", WRAM0
wMetatileMap::
    ds 16 * 16

SECTION "Map Data", WRAM0 

; Like the tile map, but for data. Collision, pits, water. 
; Storing this (redundant) map isn't great, but it allows me to update collision 
; manually without doing something weird to the tilemap. If I ever need RAM, 
; this is an easy 256 bytes.
wMapData:: 
    ds 16 * 16

SECTION "Scroll Loader Vars", WRAM0

; 4.4 positional vector keeping track of the current tile to load.
wVBlankMapLoadPosition:
    ds 1

; Which way to scroll? TRANSDIR is DIR + 1, since 0 means no scroll.
wRoomTransitionDirection::
    ; 0 == inactive
    ; FACING_ENUMS slide the camera and load the room.
    ds 1