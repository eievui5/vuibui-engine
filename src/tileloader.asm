INCLUDE "directions.inc"
INCLUDE "engine.inc"
INCLUDE "hardware.inc"
INCLUDE "lb.inc"
INCLUDE "tiledata.inc"

SECTION "Tileloader", ROM0 

; Automatically loads the entire tilemap. Screen must be off.
; @ hl: Metatiles definitions pointer
LoadMetatileMap::
    ld bc, $0000
.loop
    push hl ; A lot of stack usage? This is the slow version, who cares.
    push bc
    call LoadMetatile
    pop bc
    pop hl

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
; @ hl: Metatiles definitions pointer
LoadMetatile::
    push hl

    ld a, b ; (0 - 16) -> (0 - 32)
    add a, a  ; a * 2
    ; Add `a` to `_SCRN0` and store in `de`
    add a, LOW(_SCRN0)
    ld e, a
    adc a, HIGH(_SCRN0)
    sub a, e
    ld d, a

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
    ld a, b
    ; Add `a` to `wMetatileMap` and store in `hl`
    add a, LOW(wMetatileMap)
    ld l, a
    adc a, HIGH(wMetatileMap)
    sub a, l
    ld h, a ; add the X value
    ld a, c
    swap a ; c * 16
    ; add the Y value
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; [hl] contains our target tile.

    ; TODO: Sacrifice a bit of speed and use 16 bits.
    ld l, [hl] ; Load the tile
    ld h, 0
    ; Tiles are 4 bytes long.
    add hl, hl
    add hl, hl
    ld b, h
    ld c, l
    
    pop hl ; Definition target
    add hl, bc
    ; [hl] is now the metatile data to copy.

    ld bc, $0202 ; loop counter: b = x, c = y
.loadRow

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, [hli]
    ld [de], a
    inc de
    dec b ; Are we done with the row yet?
    jr nz, .loadRow
    dec c ; Are we done with the block yet?
    ret z
    ld b, $02 ; Neither? Next Row.
    ld a, 32 - 2
    ; Add `a` to `de`
    add a, e
    ld e, a
    adc a, d
    sub a, e
    ld d, a
    jr .loadRow


; Looks up a given metatile's data and copies it to wMapData
; @ b:  Metatile X Location (0 - 15)
; @ c:  Metatile Y Location (0 - 15)
LoadMetatileData::
    swap c ; c * 16
    ld a, c
    ; de = b + a
    add a, b ; a = low + old_l
    ld e, a  ; a = low + old_l = new_l
    adc a, 0 ; a = new_l + old_h + carry
    sub a, e ; a = old_h + carry
    ld d, a
    ld hl, wMetatileMap
    add hl, de
    ld a, [hl] ; Load the current tile
    ; Add `a` to `wMetatileData` and store in `hl`
    add a, LOW(wMetatileData)
    ld l, a
    adc a, HIGH(wMetatileData)
    sub a, l
    ld h, a 
    ld a, [hl] ; Load that tile's data.
    ld hl, wMapData
    add hl, de
    ld [hl], a
    ret

; 4 is possible on the DMG, but I think it's cutting it close.
; Try setting this to 3 if you have issues. (May require recalibrating scrolling)
TILES_PER_FRAME EQU 4

; Scroll the screen while loading a map and adjust sprites to show new enemies
; and hide old ones.

; UNFINISHED
ScrollLoader::

; Initialize direction starting position
    ; Use 15 when possible.
    ld a, [wRoomTransitionDirection]
    ASSERT DIR_DOWN == 0
    lb bc, 15, 0 ; x, y
    and a, a
    jr z, .start
    ASSERT DIR_UP == 1
    lb bc, 15, 15
    dec a
    jr z, .start
    ASSERT DIR_RIGHT == 2
    lb bc, 0, 15
    dec a
    jr z, .start
    ASSERT DIR_LEFT == 3
    lb bc, 15, 15
    
.start ; Scrolling loop
    ; Load 8 tiles per frame.
    ldh a, [hHaltAlternate]
    inc a
    ldh [hHaltAlternate], a
    and a, %111
    jr nz, :+
    halt

    ;ld a, [wActivePlayer]
    ;ASSERT sizeof_Entity == 16
    ;swap a ; a * 16
    ;; hl = a + wPlayerArray
    ;add a, LOW(wPlayerArray + Entity_YVel)
    ;ld l, a
    ;ld h, HIGH(wPlayerArray)
    ;call MoveNoClip

:
; Load Colors
    ldh a, [hSystem]
    and a, a
    jr z, :+ ; cgbskip
        ld hl, wMetatileAttributes
        push bc
        call LoadMetatile
        pop bc
; Load Metatiles
:   ld hl, wMetatileDefinitions
    push bc
    call LoadMetatile
    pop bc

; Increment tile position
    ld a, [wRoomTransitionDirection]
    ASSERT DIR_DOWN == 0
    and a, a
    jr z, .down
    ASSERT DIR_UP == 1
    dec a
    jr z, .up
    ASSERT DIR_RIGHT == 2
    dec a
    jr z, .right
    ASSERT DIR_LEFT == 3
.left

    ld a, b
    cp a, 15
    jr z, :+ ; skip scroll if we haven't moved yet
    ldh a, [hSCXBuffer]
    dec a
    cp a, 96 - 1
    jr z, :+
    ldh [hSCXBuffer], a
:

    ld a, c
    sub a, 1 ; dec 1 + carry flag
    ld c, a
    jr nc, .start
    ld c, 15
    ld a, b
    sub a, 1
    ld b, a
    jr nc, .start
    
    ret
.down
    ld a, c
    and a, a
    jr z, :+
    ldh a, [hSCYBuffer]
    inc a
    cp a, 1
    jr z, :+ ; Stop at Zero!
    ldh [hSCYBuffer], a
:
    ld a, b
    sub a, 1 ; dec 1 + carry flag
    ld b, a
    jr nc, .start
    ld b, 15
    inc c
    ld a, c
    cp a, 16
    jr nz, .start

    ret
.up
    ld a, c
    cp a, 15
    jr z, :+ ; skip scroll if we haven't moved yet
    ldh a, [hSCYBuffer]
    dec a
    cp a, 128 - 1
    jr z, :+
    ldh [hSCYBuffer], a
:
    ld a, b
    sub a, 1 ; dec 1 + carry flag
    ld b, a
    jp nc, .start
    ld b, 15
    ld a, c
    sub a, 1
    ld c, a
    jp nc, .start
    
    ret
.right
    ld a, b
    and a, a
    jr z, :+
    ldh a, [hSCXBuffer]
    inc a
    cp a, 1
    jr z, :+ ; Stop at Zero!
    ldh [hSCXBuffer], a
:

    ld a, c
    sub a, 1 ; dec 1 + carry flag
    ld c, a
    jp nc, .start
    ld c, 15
    inc b
    ld a, b
    cp a, 16
    jp nz, .start

    ret

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
    ld hl, wMetatileDefinitions
    call LoadMetatile
    ld a, [hSystem]
    and a, a
    jr z, :+
    ; If not on DMG, load attributes
    ld a, 1 ; Swap banks
    ldh [rVBK], a
    ld bc, $0000
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
    ld hl, wMetatileDefinitions
    call LoadMetatile    
    ldh a, [hSystem]
    and a, a
    jr z, :+
        ; If not on DMG, load attributes
        ld a, 1 ; Swap banks
        ldh [rVBK], a
        ld bc, $0000
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

; Used to load a full map of 20*18 regular tiles. LCD-Safe
; @ hl: Pointer to upper-left tile
; @ de: Pointer to source tile map
; @ b : Number of rows to copy
ScreenCopy::
    ld c, SCRN_X_B
.rowLoop
        ldh a, [rSTAT]
        and STATF_BUSY
        jr nz, .rowLoop
    ld a, [de]
    ld [hli], a
    inc de
    dec c
    jr nz, .rowLoop
    dec b
    ret z
    ld a, SCRN_VX_B - SCRN_X_B
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    jr ScreenCopy

; Used to set a full map of 20*14 regular tiles. LCD-Safe
; @ hl: Pointer to upper-left tile
; @ b : Tile ID
; @ c : Number of rows to copy
ScreenSet::
    ld d, SCRN_X_B
.rowLoop
        ldh a, [rSTAT]
        and STATF_BUSY
        jr nz, .rowLoop
    ld a, b
    ld [hli], a
    dec d
    jr nz, .rowLoop
    dec c
    ret z
    ld a, SCRN_VX_B - SCRN_X_B
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    jr ScreenSet

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
wVBlankMapLoadPosition::
    ds 1

; Which way to scroll? TRANSDIR is DIR + 1, since 0 means no scroll.
wRoomTransitionDirection::
    ; 0 == inactive
    ; FACING_ENUMS slide the camera and load the room.
    ds 1

SECTION UNION "Volatile", HRAM
hHaltAlternate:
    ds 1