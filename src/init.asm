
INCLUDE "include/bool.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/map.inc"
INCLUDE "include/players.inc"
INCLUDE "include/tiles.inc"

SECTION "Initialize", ROM0
; Inits system value based off `a` and `b`. Do not jump to this!
InitializeSystem::
    cp a, $11 ; The CGB boot rom sets `a` to $11
    jr nz, .dmg
    bit 0, b ; The AGB boot rom sets bit 0 of `b`
    jr z, .cgb
.agb
    ld a, SYSTEM_AGB
    jr .store
.dmg
    ASSERT SYSTEM_DMG == 0
    xor a, a ; ld a, SYSTEM_DMG
    jr .store
.cgb
    ld a, SYSTEM_CGB
.store
    ldh [hSystem], a

    ; Overclock the CGB
    and a, a
    jr z, Initialize

    ; Wait to turn off the screen, because speed switch can be finicky.
    ld a, 144
    ld hl, rLY
.waitVBlank
    cp a, [hl]
    jr nz, .waitVBlank
    xor a, a ; Turn off the screen
    ld [rLCDC], a

    ld a, 1
    ld [rKEY1], a
    stop
    jr Initialize.waitSkip

Initialize::
    ; Wait to turn off the screen
    ld a, 144
    ld hl, rLY
.waitVBlank
    cp a, [hl]
    jr nz, .waitVBlank
    xor a, a ; Turn off the screen
    ld [rLCDC], a
.waitSkip

; Enable interrupts
    xor a, a
    ldh [rIF], a ; Clear queued interrupts (always gonna be VBlank)
    ld a, IEF_VBLANK | IEF_LCDC
    ldh [rIE], a
    ld a, STATF_LYC
    ldh [rSTAT], a
    ld a, 144 - 16
    ldh [rLYC], a

; Clear VRAM
    ld hl, _VRAM
    ld bc, $2000
    xor a, a
    call memset
    ld hl, $C000
    ld bc, $2000
    call memset


; Reset Stack to WRAMX
    ld sp, wStackOrigin

; Initialize high ram
    xor a, a
    ldh [hCurrentKeys], a
    ldh [hNewKeys], a
    ASSERT ENGINE_STATE_NORMAL == 0
    ldh [hEngineState], a
    xor a, a ; ld a, 0
    ld bc, wShadowOAM.end - wShadowOAM
    ld hl, _OAMRAM
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
    ld hl, vPlainTiles
    ; Light
    ld b, 8
:   ld a, $FF
    ld [hli], a
    xor a, a
    ld [hli], a
    dec b
    jr nz, :-
    ; Dark
    ld b, 8
:   xor a, a
    ld [hli], a
    ld a, $FF
    ld [hli], a
    dec b
    jr nz, :-
    ; Black
    ld a, $FF
    ld bc, $0010
    ld hl, $97F0
    call memset

;Load Tiles
    ; Octavia
    ld hl, GfxOctavia
    ld de, VRAM_TILES_OBJ + TILE_OCTAVIA_DOWN_1 * $10
    ld bc, (GfxOctavia.end - GfxOctavia) * 3
    call memcopy

    ; Debug Tiles
    ld c, DebugTiles.end - DebugTiles
    ld hl, DebugTiles
    ld de, VRAM_TILES_BG
    rst memcopy_small
    
    ; Debug Metatiles
    ld c, DebugMetatileDefinitions.end - DebugMetatileDefinitions
    ld hl, DebugMetatileDefinitions
    ld de, wMetatileDefinitions ; Metatiles must be defined
    rst memcopy_small

    ld c, DebugMetatileAttributes.end - DebugMetatileAttributes
    ld hl, DebugMetatileAttributes
    ld de, wMetatileAttributes ; Metatile attributes must be defined
    rst memcopy_small

    ld c, DebugMetatileData.end - DebugMetatileData
    ld hl, DebugMetatileData
    ld de, wMetatileData ; Metatile data must be defined
    rst memcopy_small

    ; Debug Map
    ld a, TRUE
    call UpdateActiveMap

    ; Load metatiles onto _SCRN0
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatileMap
    ldh a, [hSystem]
    and a, a
    jr z, :+
    ld a, 1
    ldh [rVBK], a
    ld de, _SCRN0
    ld hl, wMetatileAttributes
    call LoadMetatileMap
    xor a, a
    ldh [rVBK], a
:    
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
    ldh a, [hSystem]
    and a, a
    jr nz, .cgbPal
.dmgPal
    ld a, %11100100 ; Black, Dark, Light, White
    ld [wBGP], a
    ld a, %11010000 ; Black, Light, White (Normal)
    ld [wOBP0], a
    ld a, %00011100 ; White, Light, Black (Damage)
    ld [wOBP1], a
    jr .palReset
.cgbPal
    ld hl, PalOctavia
    ld c, sizeof_PALETTE
    ld de, wBCPD
    rst memcopy_small
    ld hl, PalTiber
    ld c, sizeof_PALETTE
    rst memcopy_small
    ld hl, PalOctavia
    ld c, sizeof_PALETTE * 4
    ld de, wOCPD
    rst memcopy_small
.palReset
    ld a, PALETTE_STATE_RESET
    ld [wPaletteState], a

.initPlayers
; Initialize Player Array
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

    ld hl, _VRAM + (TILE_ARROW_DOWN * $10)
    ld de, pb16_GfxArrow
    ld b, 6
    call pb16_unpack_block

    ld a, ITEM_HEAL_WAND << 4 | ITEM_FIRE_WAND
    ld [wPlayerEquipped.octavia], a
    ld a, ITEM_BOW << 4
    ld [wPlayerEquipped.poppy], a
    ld a, ITEM_SWORD
    ld [wPlayerEquipped.tiber], a

; Re-enable the screen
    ld a, SCREEN_NORMAL
    ld [rLCDC], a
    ei

    jp Main