
; Root

include "include/hardware.inc"
include "include/defines.inc"
include "include/tiles.inc"

include "source/standard/memover.asm"
include "source/standard/memcopy.asm"
include "source/standard/input.asm"

include "source/tiles.asm"
include "source/tileloader.asm"
include "source/entities/entities.asm"

include "gfx/graphics.asm"            

SECTION "VBlankInterrupt", ROM0[$40]
    ; Save register state
    push af
    push bc
    push de
    push hl
    jp VBlank


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

; Enable VBlank interrupts
    ld a, IEF_VBLANK
    ld [rIE], a

; Clear VRAM, SRAM, and WRAM
    ld hl, _VRAM
    ld bc, RAM_LENGTH * 3
    xor a
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

; add a black tile to ram
    ld a, $FF
    ld bc, $0010
    ld hl, $8010
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
    ld bc, DebugTilemap.end - DebugTilemap
    ld hl, DebugTilemap
    ld de, wMetatileMap
    call MemCopy

    ld de, _SCRN0
    ld hl, wMetatileDefinitions
    call LoadMetatileMap
    ld de, wMapData
    ld hl, wMetatileData
    call LoadMetatileMap

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
    ld a, LCDCF_ON | LCDCF_OBJON | LCDCF_BGON | LCDCF_OBJ16
    ld [rLCDC], a
; Reset Stack
    ld sp, wStackOrigin 
    ei

    ld de, DebugPlayer ; Spawn controllable entity at 16, 16
    ld bc, $1060
    call SpawnEntity

Main:
    xor a ; ld a, 0
    ld bc, wShadowOAM.end - wShadowOAM
    ld hl, wShadowOAM
    call MemOver
    ldh [hOAMIndex], a ; Reset the OAM index.

    call HandleEntities

    halt
    nop
    jr Main


_hl_::
    jp hl

SECTION "VBlank", ROM0
; Verticle Screen Blanking
VBlank:
    ; push wShadowOAM to OAM though DMA
    ld a, high(wShadowOAM)
    call hOAMDMA

    ; There is minimal room to load a few tiles here.

    ; Updating Input should happen last, since it does not rely on VBlank
    call UpdateInput

    ; Restore register state
    pop hl
    pop de
    pop bc
    pop af
    reti


SECTION "OAM DMA routine", ROM0
; OAM DMA prevents access to most memory, but never HRAM.
; This routine starts an OAM DMA transfer, then waits for it to complete.
; It gets copied to HRAM and is called there from the VBlank handler
OAMDMA:
	ldh [rDMA], a
	ld a, MAXIMUM_SPRITES
.wait
	dec a
	jr nz, .wait
	ret
.end


SECTION UNION "Shadow OAM", WRAM0,ALIGN[8]
wShadowOAM::
	ds MAXIMUM_SPRITES * 4
.end


SECTION "OAM DMA", HRAM
; Location of the copied OAM DMA Routine
hOAMDMA:
	ds OAMDMA.end - OAMDMA


; Stack Allocation
STACK_SIZE EQU 32 * 2
SECTION "Stack", WRAMX[$E000 - STACK_SIZE]
    ds STACK_SIZE
wStackOrigin:


SECTION "OAM Index", HRAM
; Used to order sprites in shadow OAM
hOAMIndex:: ds 1