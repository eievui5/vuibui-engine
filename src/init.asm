INCLUDE "banks.inc"
INCLUDE "engine.inc"
INCLUDE "entity.inc"
INCLUDE "graphics.inc"
INCLUDE "hardware.inc"
INCLUDE "map.inc"
INCLUDE "players.inc"
INCLUDE "stat.inc"
INCLUDE "stdopt.inc"
INCLUDE "text.inc"
INCLUDE "tiledata.inc"

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
        rst MemSetSmall
        ; Clear Static FX
        ld [wStaticFX], a
        ; Clear palettes and target palettes
        ld hl, wBCPD
        ld c, sizeof_PALETTE * 16
        rst MemSetSmall
        ; Seed the randstate
        ld hl, randstate
        ld c, 4
        rst MemSetSmall
        ld [wPaletteState], a
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
        ld c, 16
        ld hl, vBlankTile
        call MemSetSmall
        ld a, 1
        ldh [rVBK], a
        xor a, a
        ld hl, _VRAM
        ld bc, $2000
        call MemSet
        ldh [rVBK], a
        ld hl, _VRAM
        ld bc, $2000
        call MemSet
    ; SRAM
        call VerifySRAM

    ; Set the palette target to white for now.
    ld a, $FF
    ld hl, wBCPDTarget
    ld bc, sizeof_PALETTE * 16
    rst MemSetSmall

    ld a, 16
    ld [wFadeSpeed], a

; Load OAM Routine into HRAM
	ld hl, OAMDMA
	lb bc, OAMDMA.end - OAMDMA, LOW(hOAMDMA)
.copyOAMDMA
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, .copyOAMDMA

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

    ; Copy the four default object palettes
    lb bc, BANK(PalPlayers), sizeof_PALETTE * 4
    ld de, wOCPD
    ld hl, PalPlayers
    call MemCopyFar
.palReset
    ; Force-update while the screen is off
    ld a, PALETTE_STATE_RESET
    call UpdatePalettes

; Set up Menu
    ld a, ENGINE_STATE_MENU
    ldh [hEngineState], a

    ld de, TitlescreenHeader
    ld b, BANK(TitlescreenHeader)
    call AddMenu

    jp Main

; Initiallizes memory to restart gameplay. Will be replaced with a default save file.
InitializeGameplay::

.waitVBlank
    ldh a, [rLY]
    cp a, SCRN_Y
    jr c, .waitVBlank

    xor a, a
    ldh [rLCDC], a

    ldh a, [hCurrentBank]
    push af

    call ResetOAM

; Clean and initialize player array.

    ; Until there is a save file, just zero-init the player variables
    ld c, SIZEOF("Player Variables")
    ld hl, STARTOF("Player Variables")
    rst MemSetSmall
    ld [wPoppyActiveArrows], a

    ; Set up players and clear array.
    ld hl, wOctavia
    ld a, HIGH(PlayerOctavia)
    ld [hli], a
    ld a, LOW(PlayerOctavia)
    ld [hli], a
    xor a, a
    ld c, sizeof_Entity - 2
    rst MemSetSmall

    ld a, HIGH(PlayerPoppy)
    ld [hli], a
    ld a, LOW(PlayerPoppy)
    ld [hli], a
    xor a, a
    ld c, sizeof_Entity - 2
    rst MemSetSmall

    ld a, HIGH(PlayerTiber)
    ld [hli], a
    ld a, LOW(PlayerTiber)
    ld [hli], a
    xor a, a
    ld c, sizeof_Entity - 2
    rst MemSetSmall

; Load the player's graphics
    call LoadStandardGraphics

; UI graphics
    ; Heart graphics
    ld a, BANK(GfxHeart)
    rst SwapBank
    ld c, GfxHeart.end - GfxHeart
    ld de, vHeart
    ld hl, GfxHeart
    call VRAMCopySmall
    ; Button hints
    ld a, BANK(GameFont)
    rst SwapBank
    get_character "A"
    ld de, vAHint
    ld c, 8 * 2
    call Unpack1bpp

; Reset HUD
    call ResetHUD
    ld a, 1
    ld [wEnableHUD], a
    xor a, a
    ld [wPrintState], a

; Load save file 0
    ld a, BANK("Manage Save File")
    rst SwapBank
    ; Load save file 0
    ld hl, sSave0
    call xLoadSaveFile
    call xLoadRepawnPoint

    ld a, UPDATE_TILEMAP
    call UpdateActiveMap

; Position camera
    ld a, (256 - SCRN_X)/2
    ldh [rSCX], a
    ldh [hSCXBuffer], a
    ld a, (256 - SCRN_Y)/2 - 16
    ldh [rSCY], a
    ldh [hSCYBuffer], a

    ld a, SCREEN_NORMAL
    ldh [hLCDCBuffer], a
    ld a, SKIP_FRAME
    ldh [rLCDC], a

    ASSERT ENGINE_STATE_GAMEPLAY == 0
    xor a, a
    ldh [hEngineState], a
    ldh [hPaused], a

    pop af
    rst SwapBank
    ret

LoadStandardGraphics::
    ldh a, [hCurrentBank]
    push af

    ld a, BANK(GfxOctavia)
    rst SwapBank
    ; Load player graphics
    ld hl, GfxOctavia
    ld de, _VRAM_OBJ + TILE_OCTAVIA_DOWN_1 * $10
    ld bc, (GfxOctavia.end - GfxOctavia) * 3
    call MemCopy

    ld a, BANK(GfxArrow)
    rst SwapBank
    ld c, GfxArrow.end - GfxArrow
    ld de, _VRAM + (TILE_ARROW_DOWN * $10)
    ld hl, GfxArrow
    call VRAMCopySmall

    ld a, BANK(GfxSword)
    rst SwapBank
    ld c, GfxSword.end - GfxSword
    ld de, _VRAM + (TILE_SWORD_UP * $10)
    ld hl, GfxSword
    call VRAMCopySmall

    ld a, BANK(GfxSparkle)
    rst SwapBank
    ld c, GfxSparkle.end - GfxSparkle
    ld de, _VRAM + (TILE_SPARKLE_LEFT * $10)
    ld hl, GfxSparkle
    call VRAMCopySmall

    pop af
    rst SwapBank
    ret