INCLUDE "include/hardware.inc"
INCLUDE "include/defines.inc"

SECTION "VBlankInterrupt", ROM0[$40]
    ; Save register state
    push af
    push bc
    push de
    push hl
    jp VBlank

SECTION "Main", ROMX

Main::
    call Initialize
.loop
    call EntityHandler
    halt
    nop
    jr .loop


SECTION "Entity Handler", ROMX

; Entities are structured as:
; dw Script     (+0)
; db X Loc      (+2)
; db Y Loc      (+3)

EntityHandler:
    ld b, MAXIMUM_ENTITIES
    ; Load the current entity data reference
    ld de, wActiveEntityArray
.iterate
    ld a, [de]
    inc de
    ld l, a
    ld a, [de]
    inc de
    ld h, a
    xor a ; ld a, $00
    cp h ; cp a, h
    jr z, .counter
    ; Call the entity's script.
    push de
    call _hl_
    pop de ; let the script use `de` but restore it's location to be safe.
.counter
    ; Skip the remaining data; we only care about the script (for now...)
    inc de ; X Loc
    inc de ; Y Loc
    dec b
    jr nz, .iterate
    ; End
    ret

SECTION "VBlank", ROMX

; Verticle Screen Blanking, 60x per second
VBlank:

    ; get input
    ld hl, rP1
    ld b, P1F_GET_DPAD
    ld [hl], b
    call _ret_
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    swap a
    cpl ; xor a, $FF / Flips bits
    ldh [hInputBuffer], a

    ; push wShadowOAM to OAM though DMA
    ld a, high(wShadowOAM)
    call hOAMDMA

    ; Restore register state
    pop hl
    pop de
    pop bc
    pop af
    reti


SECTION "Initiallize", ROMX

; Intialize the engine
Initialize:
    ; Wait to turn off the screen
    ld a, 144
    ld hl, rLY
.waitVBlank
    cp a, [hl]
    jr nz, .waitVBlank
    ld a, LCDCF_OFF
    ld [rLCDC], a
    ; Enable VBlank interrupts
    ld a, IEF_VBLANK
    ld [rIE], a
    ; Clear VRAM, SRAM, and WRAM
    ld hl, _VRAM
    ld bc, RAM_LENGTH * 3
    xor a
    call OverwriteBytes
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
    ; add a tile to ram
    ld a, $FF
    ld bc, $0010
    ld hl, $8010
    call OverwriteBytes
    ld a, $01
    ld [wShadowOAM+2], a

    ld bc, Player.end - Player
    ld de, wActiveEntityArray
    ld hl, Player
    call CopyBytes

    ; Re-enable the screen
    ld a, LCDCF_ON | LCDCF_OBJON
    ld [rLCDC], a
    reti


SECTION "OAM DMA routine", ROMX

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


SECTION "Process Arrays", WRAM0 
; Arrays containing pointers that are ran each frame.

; each process array holds 32 bytes, meaning 16 processes
PROCESS_SIZE EQU 16

wProcessArray:
    ds $2 * PROCESS_SIZE

wVBlankProcessArray:
    ds $2 * PROCESS_SIZE


SECTION "Variables", WRAM0 

wTestFrameCounter:
    ds $1


SECTION "OAM DMA", HRAM

hOAMDMA:
	ds OAMDMA.end - OAMDMA