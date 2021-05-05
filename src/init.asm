INCLUDE "include/banks.inc"
INCLUDE "include/bool.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/map.inc"
INCLUDE "include/players.inc"
INCLUDE "include/stat.inc"
INCLUDE "include/text.inc"
INCLUDE "include/tiledata.inc"

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
.waitVBlank
	ldh a, [rLY]
	cp a, 144
	jr c, .waitVBlank
	xor a, a
	ldh [rLCDC], a

    ld a, 1
    ld [rKEY1], a
    stop
    jr Initialize.waitSkip

Initialize::
.waitVBlank
	ldh a, [rLY]
	cp a, 144
	jr c, .waitVBlank
	xor a, a
	ldh [rLCDC], a
.waitSkip

; Enable interrupts
    ; Clear queued interrupts
    xor a, a
    ldh [rIF], a
    ; Set Interrupts
    ld a, IEF_VBLANK | IEF_LCDC
    ldh [rIE], a
    ; Configure STAT
    ld a, STATF_LYC
    ldh [rSTAT], a
    ld a, 1
    ldh [rLYC], a
    ; And enable!
    ei

; Clear VRAM
    ld hl, _VRAM
    ld bc, $2000
    xor a, a
    call memset
    ld hl, $C000
    ld bc, $1000
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
    call memset

    ld a, BANK(pb16_Heart)
    swap_bank

; load button hints
    ld de, pb16_Heart
    ld hl, VRAM_TILES_BG + TILE_HEART * 16
    ld b, 3 ; 2 tiles
    call pb16_unpack_block

    ld a, BANK(GameFont)
    swap_bank

    get_character "A"
    ld de, VRAM_TILES_BG + TILE_A_CHAR * 16
    ld c, 8 * 2
    call Unpack1bpp

; Debug Map
    ld a, SPAWN_ENTITIES | UPDATE_TILEMAP
    call UpdateActiveMap

; Load metatiles onto _SCRN0
    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatileMap
    ldh a, [hSystem]
    and a, a
    jr z, :+
    ld a, TRUE
    ldh [rVBK], a
    ld de, _SCRN0
    ld hl, wMetatileAttributes
    call LoadMetatileMap
    xor a, a
    ldh [rVBK], a
:    

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

    ld a, BANK(PalOctavia)
    swap_bank

    ; Copy the four default object palettes
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

    ld a, BANK(TiberDialoguePalette)
    ld [wTextboxPalsBank], a
    ld a, HIGH(TiberDialoguePalette)
    ld [wTextboxPalettes], a
    ld a, LOW(TiberDialoguePalette)
    ld [wTextboxPalettes + 1], a

    ld a, BANK(GfxOctavia)
    swap_bank

    ; Octavia
    ld hl, GfxOctavia
    ld de, VRAM_TILES_OBJ + TILE_OCTAVIA_DOWN_1 * $10
    ld bc, (GfxOctavia.end - GfxOctavia) * 3
    call memcopy
    
    ld a, BANK(pb16_GfxArrow)
    swap_bank
    ld hl, _VRAM + (TILE_ARROW_DOWN * $10)
    ld de, pb16_GfxArrow
    ld b, 6
    call pb16_unpack_block

    ld a, ITEM_HEAL_WAND << 4 | ITEM_FIRE_WAND
    ;ld a, ITEM_ICE_WAND << 4 | ITEM_SHOCK_WAND
    ld [wPlayerEquipped.octavia], a
    ld a, ITEM_BOW << 4
    ld [wPlayerEquipped.poppy], a
    ld a, ITEM_SWORD
    ld [wPlayerEquipped.tiber], a

    ld a, TRUE
    ld [wHUDReset], a
    ld a, 17
    ld [wOctavia_Health], a
    ld a, 23
    ld [wPoppy_Health], a
    ld a, 40
    ld [wTiber_Health], a

    ld a, 40
    ld hl, wPlayerMaxHealth
    ld [hli], a
    ld a, 40
    ld [hli], a
    ld a, 40
    ld [hli], a

; Configure STAT FX
    xor a, a
    ld hl, wRasterFX
    ld bc, 80
    call memset

    ld a, STATIC_FX_SHOW_HUD
    ld [wStaticFX], a

; Re-enable the screen
    ld a, SCREEN_NORMAL
    ld [rLCDC], a

    jp Main