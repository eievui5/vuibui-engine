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
    call Process
    halt
    nop
    jr .loop


SECTION "Process", ROMX

; Runs at 60 ticks per second.
Process:
    ; iterate though the process array.
    ld b, $00
    ; we start 1 byte behind so that our loop is more efficient
    ld de, wProcessArray - 1
.iterate
    inc b
    ; b counts the current array element. This is crucial for when elements are
    ; removed, if slow.
    ld a, b
    cp a, PROCESS_SIZE
    ret z
    inc de
    ld a, [de]
    inc de
    ; if there is nothing in the array, don't run it
    ; $00 should always be invalid, since calls should occur in a non-zero bank.
    cp a, $00
    jr z, .iterate
    ld h, a
    ld a, [de]
    ld l, a
    ; Save b and de, since the process may change them and we need them.
    push bc
    ; de can be used as a sort of identifier
    push de
    call _hl_
    pop de
    pop bc
    jr .iterate

; Moves the first sprite across the screen
TestProcess:
    ld hl, wShadowOAM
    ld a, $19
    cp [hl]
    jr nz, .increment
    ld de, TestProcess
    call RemoveProcess
.increment
    inc [hl]
    ret

TestProcess2:
    ld hl, wShadowOAM + 1
    inc [hl]
    ret

; Takes de and puts it in wProcessArray, breaking if there's not enough space.
; @ arguments:
; @ de: Process to add
; @ only preserves de and c.
RegisterProcess:
    ; offset by 2, makes iterate easier
    ld hl, wProcessArray - 2
    ld b, PROCESS_SIZE
.iterate
    ; Can be removed, for safety only 
    dec b
    jr z, .error
    ; No hli, we need to preserve hl if [hl] != 0
    inc hl
    inc hl
    ; if the first byte is empty, break. this will cause issues if the function
    ; is within the first $0000 bytes
    ld a, [hl]
    cp 0
    jr nz, .iterate
    ld [hl], d
    inc hl
    ld [hl], e
    ret
.error
    ld b, b
    di 
    stop

; Finds de and overwrites it with 0, breaking if not found.
; @ arguments:
; @ de: Process to remove
RemoveProcess:
    ; offset by 2, makes iterate easier
    ld hl, wProcessArray - 2
    ld b, PROCESS_SIZE
.iterate
    ; Can be removed, for safety only 
    dec b
    jr z, .error
    ; No hli, we need to preserve hl if [hl] != de
    inc hl
    inc hl
    ; if the first byte is empty, break. this will cause issues if the function
    ; is within the first $0000 bytes
    ld a, [hl]
    cp a, d
    jr nz, .iterate
    inc hl
    ld a, [hld]
    cp a, e
    jr nz, .iterate
    xor a
    ld [hli], a
    ld [hl], a
    ret
.error
    ld b, b
    di 
    stop


SECTION "VBlank", ROMX

; Verticle Screen Blanking, 60x per second
VBlank:

    ; VBlank processes

    ; VBlank Routine

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
    ; register the initial process
    ld de, TestProcess
    call RegisterProcess
    ld de, TestProcess2
    call RegisterProcess
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