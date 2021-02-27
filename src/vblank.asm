
include "include/hardware.inc"
include "include/defines.inc"

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
    ld a, [wRoomTransitionFlag]
    and a, a
    jr z, .scrolling

    ld a, b
    and a, a
    jr nz, .skipFirst
    ; This part's a bit hacky, but since $00 ends the loop, we just throw it in here.
    ; This means that $0000 loads first, even when moving left. Don't worry about it.
    ld bc, $0000
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatile
.skipFirst
    ld a, [wRoomTransitionFlag]

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
    ld [wRoomTransitionFlag], a
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
    ld a, DIRECTION_DOWN
    ld [wRoomTransitionFlag], a

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
    cp a, 255 - 160 ; Is A past the screen bounds?
    jr nc, .storeY
    ld [wSCXBuffer], a
.storeY
    ld a, e
    cp a, 255 - 144 ; Is A past the screen bounds?
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

wRoomTransitionFlag::
    ; 0 == inactive
    ; FACING_ENUMS slide the camera and load the room.
    ds 1