
; Root

include "include/hardware.inc"
include "include/defines.inc"
include "include/tiles.inc"
include "include/map.inc"
include "include/engine.inc"

include "gfx/graphics.asm"

SECTION "Header", ROM0[$100]
	di
	jp Initialize
	ds $150 - $104, 0


SECTION "Initialize", ROM0
Initialize:
    
    ; Wait to turn off the screen
    ld a, 144
    ld hl, rLY
.waitVBlank
    cp a, [hl]
    jr nz, .waitVBlank
    xor a ; Turn off the screen
    ld [rLCDC], a

; Enable interrupts
    ld a, IEF_VBLANK | IEF_LCDC
    ldh [rIE], a
    ld a, STATF_LYC
    ldh [rSTAT], a
    ld a, 144 - 16
    ldh [rLYC], a

; Clear VRAM, SRAM, and WRAM
    ld hl, _VRAM
    ld bc, RAM_LENGTH * 3
    xor a
    call MemOver

; Reset Stack to WRAMX
    ld sp, wStackOrigin 

; Clear HRAM
    ld hl, _HRAM
    ld bc, $FFFE - _HRAM
    call MemOver

; Load the OAM Routine into HRAM
	ld hl, OAMDMA
	ld b, OAMDMA.end - OAMDMA 
    ld c, LOW(hOAMDMA)
.copyOAMDMA
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, .copyOAMDMA

    ; Copy Plain Tiles
    ld bc, PlainTiles.end - PlainTiles
    ld de, $97D0
    ld hl, PlainTiles
    call MemCopy
    ; Copy Plain Tiles
    ld bc, PlainTiles.end - PlainTiles
    ld de, $87E0
    ld hl, PlainTiles
    call MemCopy
; add a black tile to ram
    ld a, $FF
    ld bc, $0010
    ld hl, $97F0
    call MemOver

;Load Tiles
    ; Octavia
    ld bc, GfxOctaviaMain.end - GfxOctaviaMain
    ld hl, GfxOctaviaMain
    ld de, VRAM_TILES_OBJ
    call MemCopy

    ; Debug Tiles
    ld bc, DebugTiles.end - DebugTiles
    ld hl, DebugTiles
    ld de, VRAM_TILES_BG
    call MemCopy
    
    ; Debug Metatiles
    ld bc, DebugMetatileDefinitions.end - DebugMetatileDefinitions
    ld hl, DebugMetatileDefinitions
    ld de, wMetatileDefinitions ; Metatiles must be defined
    call MemCopy

    ld bc, DebugMetatileData.end - DebugMetatileData
    ld hl, DebugMetatileData
    ld de, wMetatileData ; Metatile data must be defined
    call MemCopy

    ; Debug Map
    call GetActiveMap ; map pointer -> hl
    ld bc, MAP_SIZE
    ld de, wMetatileMap
    call MemCopy

    ; Load metatiles onto _SCRN0
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatileMap
    
    call LoadMapData
    
    ; Place window
    ld a, 7
    ldh [rWX], a
    ld a, 144 - 16
    ldh [rWY], a

    ; Enable audio
    ld a, $80
    ld [rAUDENA], a
    ld a, $FF
    ld [rAUDTERM], a
    ld a, $FF
    ld [rAUDVOL], a

; Configure Default Pallet
    ld a, %11100100 ; Black, Dark, Light, White
    ld hl, rBGP
    ld [hl], a
    ld a, %11010000 ; Black, Light, White (Normal)
    ld hl, rOBP0
    ld [hl], a
    ld a, %00011100 ; White, Light, Black (Damage)
    ld hl, rOBP1
    ld [hl], a

; Re-enable the screen
    ld a, SCREEN_NORMAL
    ld [rLCDC], a
    ei

    ld a, 1
    ld [wActivePlayer], a

    ld a, high(PlayerOctavia)
    ld hl, wPlayerArray
    ld [hli], a
    ld a, low(PlayerOctavia)
    ld [hl], a

    ld de, HitDummy
    ld bc, $8020
    call SpawnEntity
    ld bc, $6060
    call SpawnEntity
    ld bc, $2020
    call SpawnEntity
    jp Main 

SECTION "Main Loop", ROM0

; Split these up into an engine state jump table. Engine should only call out so that code can be reused.
Main:

    ; Check engine state
    ; TODO: make this offset OAM during Scrolling
    ldh a, [hEngineState]
    and a, a
    ASSERT ENGINE_NORMAL == 0
    jr z, .cleanOAM
    ASSERT ENGINE_SCRIPT == 1
    dec a
    jr z, .handleScript
    ASSERT ENGINE_ROOM_TRANSITION == 2
    jr .end

.handleScript
    ;call RenderEntities
    call HandleScript
    jr .end

.cleanOAM
    xor a ; ld a, 0
    ld bc, wShadowOAM.end - wShadowOAM
    ld hl, wShadowOAM
    call MemOver
    ldh [hOAMIndex], a ; Reset the OAM index.

.cyclePlayers
    ldh a, [hNewKeys]
    bit PADB_SELECT, a
    jr z, .updateMap
    ld hl, wActivePlayer ; Using hl is 1 byte & 1 cycle less
    ld a, [hl]
    inc a
    and a, 3 ; cp a, 3 + 1 (Since 4 is it's own bit...)
    jr nz, .skipp
    ld a, 1
.skipp
    ld [hl], a

.updateMap
    ld a, [wUpdateMapDataFlag]
    and a, a
    jr z, .entities 
    call LoadMapData
    xor a
    ld [wUpdateMapDataFlag], a

.entities
    call HandleEntities
    call RenderEntities

.end
    ; When main is unhalted we ensure that it will not loop.
    xor a, a
    ld [wNewFrame], a
    halt
    ld a, [wNewFrame]
    and a, a
    jr z, .end
    xor a, a
    ld [wNewFrame], a
    jr Main

SECTION "Plain Tiles", ROMX

; It's more efficient to MemCopy these. (Not really)
PlainTiles:
    ; Light
    db $FF, $00, $FF, $00
    db $FF, $00, $FF, $00
    db $FF, $00, $FF, $00
    db $FF, $00, $FF, $00
    ; Dark
    db $00, $FF, $00, $FF
    db $00, $FF, $00, $FF
    db $00, $FF, $00, $FF
    db $00, $FF, $00, $FF
.end

SECTION "Main Vars", WRAM0
wUpdateMapDataFlag::
    ds 1

; if != 0, restart main loop
wNewFrame::
    ds 1

SECTION "Engine Flags", HRAM
hEngineState::
    ds 1 

; Stack Allocation
STACK_SIZE EQU 32 * 2
SECTION "Stack", WRAMX[$E000 - STACK_SIZE]
    ds STACK_SIZE
wStackOrigin:
