
include "include/hardware.inc"
include "include/defines.inc"

; 4 is possible on the DMG, but I think it's cutting it close.
; Try setting this to 3 if you have issues.
TILES_PER_FRAME EQU 4

SECTION "VBlank", ROM0
; Verticle Screen Blanking
VBlank::
.dma
    ; push wShadowOAM to OAM though DMA
    ld a, high(wShadowOAM)
    call hOAMDMA

    ; There is minimal room to load a few tiles here.

.metatileLoading
    ; Load a metatile if needed
    ld a, [wVBlankMapLoadPosition]
    ld b, a
    ld a, [wRoomTransitionDirection]
    and a, a
    jp z, .scrolling ; Too far for jr!


    ld a, b
    ld b, TILES_PER_FRAME ; Save the index up here so that we can push in the loop
    and a, a
    jr nz, .skipFirst
    ; If this is our first pass, tell the Main loop to load tile data.
    inc a ; We just need a != 0, and this is fast.
    ld [wUpdateMapDataFlag], a
    ld a, [wRoomTransitionDirection]
    ; Up and left must not load the 0 tile until the end.
    cp a, DIRECTION_UP
    jr z, .skipFirst
    cp a, DIRECTION_LEFT
    jr z, .skipFirst
    ld bc, $0000
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatile
    ld b, TILES_PER_FRAME - 1 ; Keep track of the extra tile so that we're not overloaded.
.skipFirst
    push bc ; Save that index...
    ld a, [wVBlankMapLoadPosition]
    ld b, a
    ld a, [wRoomTransitionDirection]

    ASSERT DIRECTION_DOWN == 1
    dec a
    jr z, .loadDown
    ASSERT DIRECTION_UP == 2
    dec a
    jr z, .loadUp
    ASSERT DIRECTION_RIGHT == 3
    ; Left and Right both need b swapped
    swap b
    dec a
    jr z, .loadRight
    ASSERT DIRECTION_LEFT == 4
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
    ; The 0 tile still needs to be loaded.
    ; Don't worry about overwriting it if it's already there.
    ld bc, $0000
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatile
    jr .scrolling

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

    ; push bc here for GBC map.

    ; Load tiles onto _SCRN0 from the wMetatileDefinitions.
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatile

    ; pop bc and swap VRAM Banks for color.

    ; We can load more than one tile, so lets see how many are left.
    pop bc ; Remember the tile index? 
    dec b
    jr nz, .skipFirst ; Still more? Keep going!
    ld a, [wVBlankMapLoadPosition]
    ; Only move the player/screen after the first row is done.
    and a, %11110000
    jr z, .input
    cp a, $F0 
    jr z, .input

    ; Update the position of the active player.

    ; Scrolling logic, then fall through ↓
    ld a, [wRoomTransitionDirection]
    ASSERT DIRECTION_DOWN == 1
    dec a
    jr z, .scrollDown
    ASSERT DIRECTION_UP == 2
    dec a
    jr z, .scrollUp
    ASSERT DIRECTION_RIGHT == 3
    dec a
    jr z, .scrollRight
    ASSERT DIRECTION_LEFT == 4
    jr .scrollLeft

.scrollDown
    ld a, [wSCYBuffer]
    and a, a
    jr z, .input ; We can skip scrolling :)
    inc a
    jr z, .storeY
    inc a
    jr z, .storeY
    inc a
    jr .storeY
.scrollUp
    ld a, [wSCYBuffer]
    sub a, 256 - 144 ; This might be dumb.
    jr z, .input ; We can skip scrolling :)
    dec a
    jr z, .storeDown
    dec a
    jr z, .storeDown
    dec a
.storeDown
    add a, 256 - 144 ; Fix offset
.storeY
    ld [wSCYBuffer], a
    jr .scrolling
.scrollRight
    ld a, [wSCXBuffer]
    and a, a
    jr z, .input ; We can skip scrolling :)
    inc a
    jr z, .storeX
    inc a
    jr z, .storeX
    inc a
    jr .storeX
.scrollLeft
    ld a, [wSCXBuffer]
    sub a, 256 - 160 ; This might be dumb.
    jr z, .input ; We can skip scrolling :)
    dec a
    jr z, .storeLeft
    dec a
    jr z, .storeLeft
    dec a
.storeLeft
    add a, 256 - 160 ; Fix offset
.storeX
    ld [wSCXBuffer], a

.scrolling
    ; Update screen scrolling here to avoid tearing. 
    ; This is low priority, but should happen at a point where the screen will not be torn.
    ; Smooth the screen scrolling, so that jumping between players is not jarring.
    ld a, [wSCXBuffer]
    ldh [rSCX], a
    ld a, [wSCYBuffer]
    ldh [rSCY], a

.input
    ; Updating Input should happen last, since it does not rely on VBlank
    call UpdateInput
    ; Delemt me
    ldh a, [hCurrentKeys]
    bit PADB_START, a
    jr z, .return
    ld a, DIRECTION_UP
    ld [wRoomTransitionDirection], a

.return
    ; Restore register state
    pop hl
    pop de
    pop bc
    pop af
    reti

; Stores de into the scroll buffers, making sure not to leave the screen bounds. Only a is used.
; @ d:  X
; @ e:  Y
SetScrollBuffer::
    ld a, d
    cp a, 256 - 160 + 1 ; Is A past the screen bounds?
    jr nc, .storeY
    ld [wSCXBuffer], a
.storeY
    ld a, e
    cp a, 256 - 144 + 1 ; Is A past the screen bounds?
    ret nc
    ld [wSCYBuffer], a
    ret


SECTION "VBlank Vars", WRAM0

wSCXBuffer::
    ds 1

wSCYBuffer::
    ds 1

; 4.4 positional vector keeping track of the current tile to load.
wVBlankMapLoadPosition::
    ds 1

wRoomTransitionDirection::
    ; 0 == inactive
    ; FACING_ENUMS slide the camera and load the room.
    ds 1