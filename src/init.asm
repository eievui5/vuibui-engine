INCLUDE "include/banks.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/entity.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/map.inc"
INCLUDE "include/players.inc"
INCLUDE "include/stat.inc"
INCLUDE "include/text.inc"
INCLUDE "include/tiledata.inc"

SECTION "Header", ROM0[$100]
	di
	jp InitializeSystem
	ds $150 - $104, 0

SECTION "Initialize", ROM0
; Inits system value based off `a` and `b`. Do not jump to this!
InitializeSystem:
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
    ldh [rKEY1], a
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

; Reset Stack to WRAMX
    ld sp, wStackOrigin

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

; Zero-Initiallized RAM
    xor a, a
    ; HRAM
        ldh [hCurrentKeys], a
        ldh [hNewKeys], a
        ldh [hSCXBuffer], a
        ldh [hSCYBuffer], a
    ; WRAM
        call ResetOAM
        ; Reset FX Mode to STATIC
        ld [wStatFXMode], a
        ; Clear Raster Array
        ld hl, wRasterFX
        ld c, 80
        rst memset_small
        ; Clear Static FX
        ld [wStaticFX], a
        ; Clear palettes and target palettes
        ld hl, wBCPD
        ld c, sizeof_PALETTE * 16
        rst memset_small
        
        ld hl, randstate
        ld c, 4
        rst memset_small

        ld [wPaletteThread], a
        ld [wNbMenus], a
        ld [wRoomTransitionDirection], a
        ld [wTextState], a
        ld [wEnableHUD], a
        ld [wFrameTimer], a
        ld [wTextboxFadeProgress], a
        ld [wVBlankMapLoadPosition], a
        ld hl, wActiveScriptPointer
        ld [hli], a
        ld [hli], a
        ld [hli], a

    ; VRAM
        ld hl, _VRAM
        ld bc, $2000
        call memset

    ; Set the palette target to white for now.
    ld a, $FF
    ld hl, wBCPDTarget
    ld bc, sizeof_PALETTE * 16
    rst memset_small
    
    ld a, 16
    ld [wFadeSpeed], a

; Load OAM Routine into HRAM
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
    ld c, sizeof_TILE
    rst memset_small

; Configure audio
    call audio_init

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
    ld hl, PalPlayers
    ld c, sizeof_PALETTE * 4
    ld de, wOCPD
    rst memcopy_small
.palReset
    ; Force-update while the screen is off
    ld a, PALETTE_STATE_RESET
    call UpdatePalettes

; Set up Menu
    ld a, ENGINE_STATE_MENU
    ldh [hEngineState], a

    ld de, TestMenuHeader
    ld b, BANK("Menu Test")
    call AddMenu

    jp Main

; Initiallizes memory to restart gameplay. Will be replaced with a default save file.
InitializeGameplay::

.waitVBlank
    ld a, [rLY]
    cp a, SCRN_Y
    jr c, .waitVBlank

    xor a, a
    ld [rLCDC], a

    ldh a, [hCurrentBank]
    push af

    call ResetOAM

; Clean and initialize player array.

    ; Until there is a save file, just zero-init the player variables
    ld c, SIZEOF("Player Variables")
    ld hl, STARTOF("Player Variables")
    rst memset_small
    ld [wPoppyActiveArrows], a

    ld a, ITEMF_FIRE_WAND | ITEMF_SHOCK_WAND | ITEMF_ICE_WAND | ITEMF_HEAL_WAND
    ld [wItems.octavia], a
    ld a, ITEMF_SWORD
    ld [wItems.poppy], a
    ld [wItems.tiber], a
    ld a, ITEM_FIRE_WAND | ITEM_ICE_WAND << 4
    ld [wPlayerEquipped.octavia], a

    ld a, high(PlayerOctavia)
    ld hl, wOctavia
    ld [hli], a
    ld a, low(PlayerOctavia)
    ld [hli], a
    ld a, 256/2
    ld [hli], a
    ld a, 256/2
    ld [hli], a
    xor a, a
    ld c, sizeof_Entity - Entity_XPos - 1
    rst memset_small

    ld a, high(PlayerPoppy)
    ld [hli], a
    ld a, low(PlayerPoppy)
    ld [hli], a
    ld a, 256/2
    ld [hli], a
    ld a, 256/2 - 16
    ld [hli], a
    xor a, a
    ld c, sizeof_Entity - Entity_XPos - 1
    rst memset_small

    ld a, high(PlayerTiber)
    ld [hli], a
    ld a, low(PlayerTiber)
    ld [hli], a
    ld a, 256/2
    ld [hli], a
    ld a, 256/2 + 16
    ld [hli], a
    xor a, a
    ld c, sizeof_Entity - Entity_XPos - 1
    rst memset_small

; Player health
    ld a, 10
    ld hl, wPlayerMaxHealth
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [wOctavia_Health], a
    ld [wPoppy_Health], a
    ld [wTiber_Health], a

; Load the player's graphics
    call LoadPlayerGraphics

; UI graphics
    ; Heart graphics
    ld a, BANK(pb16_Heart)
    swap_bank
    ld de, pb16_Heart
    ld hl, VRAM_TILES_BG + TILE_HEART * 16
    ld b, 3 ; 2 tiles
    call pb16_unpack_block
    ; Button hints
    ld a, BANK(GameFont)
    swap_bank
    get_character "A"
    ld de, VRAM_TILES_BG + TILE_A_CHAR * 16
    ld c, 8 * 2
    call Unpack1bpp

; Reset HUD
    call ResetHUD
    ld a, 1
    ld [wEnableHUD], a
    xor a, a
    ld [wPrintState], a

; Default map

    xor a, a
    ld [wWorldMapPositionX], a
    ld [wWorldMapPositionY], a
    ld [wActiveWorldMap], a

    ld a, SPAWN_ENTITIES | UPDATE_TILEMAP
    call UpdateActiveMap

; Position camera
    ld a, (256 - SCRN_X)/2
    ldh [rSCX], a
    ldh [hSCXBuffer], a
    ld a, (256 - SCRN_Y)/2 - 16
    ldh [rSCY], a
    ldh [hSCYBuffer], a

    ld a, SCREEN_NORMAL
    ld [hLCDCBuffer], a
    ld a, SKIP_FRAME
    ld [rLCDC], a

    ASSERT ENGINE_STATE_GAMEPLAY == 0
    xor a, a
    ldh [hEngineState], a
    ldh [hPaused], a

    pop af
    swap_bank
    ret