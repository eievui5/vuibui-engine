
; Root

INCLUDE "include/bool.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/map.inc"
INCLUDE "include/players.inc"
INCLUDE "include/tiles.inc"

INCLUDE "gfx/graphics.asm"

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
    xor a, a ; Turn off the screen
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
    ld bc, $2000 * 3
    xor a, a
    call memset

; Reset Stack to WRAMX
    ld sp, wStackOrigin 

; Clear HRAM
    ld hl, _HRAM
    ld bc, $FFFE - _HRAM
    call memset

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
    call memcopy
; add a black tile to ram
    ld a, $FF
    ld bc, $0010
    ld hl, $97F0
    call memset

;Load Tiles
    ; Octavia
    ld bc, GfxOctaviaMain.end - GfxOctaviaMain
    ld hl, GfxOctaviaMain
    ld de, VRAM_TILES_OBJ
    call memcopy

    ; Debug Tiles
    ld bc, DebugTiles.end - DebugTiles
    ld hl, DebugTiles
    ld de, VRAM_TILES_BG
    call memcopy
    
    ; Debug Metatiles
    ld bc, DebugMetatileDefinitions.end - DebugMetatileDefinitions
    ld hl, DebugMetatileDefinitions
    ld de, wMetatileDefinitions ; Metatiles must be defined
    call memcopy

    ld bc, DebugMetatileData.end - DebugMetatileData
    ld hl, DebugMetatileData
    ld de, wMetatileData ; Metatile data must be defined
    call memcopy

    ; Debug Map
    ld a, TRUE
    call UpdateActiveMap

    ; Load metatiles onto _SCRN0
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatileMap
    
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
    ldh [rBGP], a
    ld [wBGP], a
    ld a, %11010000 ; Black, Light, White (Normal)
    ldh [rOBP0], a
    ld [wOBP0], a
    ld a, %00011100 ; White, Light, Black (Damage)
    ldh [rOBP1], a
    ld [wOBP1], a

; Initiallize Player Array
    ld a, high(PlayerOctavia)
    ld hl, wOctavia
    ld [hli], a
    ld a, low(PlayerOctavia)
    ld [hli], a
    ld a, 256/2
    ld [hli], a
    ld a, 256/2
    ld [hli], a
    ld a, high(PlayerPoppy)
    ld hl, wPoppy
    ld [hli], a
    ld a, low(PlayerPoppy)
    ld [hli], a
    ld a, 256/2
    ld [hli], a
    ld a, 256/2 - 16
    ld [hli], a
    ld a, high(PlayerTiber)
    ld hl, wTiber
    ld [hli], a
    ld a, low(PlayerTiber)
    ld [hli], a
    ld a, 256/2
    ld [hli], a
    ld a, 256/2 + 16
    ld [hli], a

    ld a, ITEM_FIRE_WAND << 4 | ITEM_ICE_WAND
    ld [wPlayerEquipped.octavia], a

; Re-enable the screen
    ld a, SCREEN_NORMAL
    ld [rLCDC], a
    ei

    jp Main 

SECTION "Main Loop", ROM0

; Split these up into an engine state jump table.
; Engine should only call out so that code can be reused.
Main::

.cleanOAM
    xor a ; ld a, 0
    ld bc, wShadowOAM.end - wShadowOAM
    ld hl, wShadowOAM
    call memset
    ldh [hOAMIndex], a ; Reset the OAM index.

    ; Check engine state
    ; TODO: make this offset OAM during Scrolling
    ldh a, [hEngineState]
    and a, a
    ASSERT ENGINE_STATE_NORMAL == 0
    jr z, .handleNormal
    ASSERT ENGINE_STATE_SCRIPT == 1
    dec a
    jr z, .handleScript
    ASSERT ENGINE_STATE_ROOM_TRANSITION == 2

.handleTransition
    call RenderPlayersTransition
    call PlayerTransitionMovement
    jr .end

.handleScript
    call RenderEntities
    call HandleScript
    jr .end

.handleNormal
.entities
    call HandleEntities
    call PlayerCameraInterpolation ; Update camera!

    call RenderEntities

.end::
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

; It's more efficient to memcopy these. (Not really)
PlainTiles:
    ; Light
    ds 16, $FF, $00
    ; Dark
    ds 16, $00, $FF
.end

SECTION "Main Vars", WRAM0

; if != 0, restart main loop
wNewFrame::
    ds 1

SECTION "Engine Flags", HRAM
hEngineState::
    ds 1 

; Stack Allocation
DEF STACK_SIZE EQU 32 * 2
SECTION "Stack", WRAMX[$E000 - STACK_SIZE]
    ds STACK_SIZE
wStackOrigin::
