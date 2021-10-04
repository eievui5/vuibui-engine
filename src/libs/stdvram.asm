INCLUDE "hardware.inc"

SECTION "VRAM Memory Copy", ROM0
; Waits for VRAM access before copying data.
; @ bc: length
; @ de: destination
; @ hl: source
VRAMCopy::
    dec bc
    inc b
    inc c
.loop:
    ldh a, [rSTAT]
    and STATF_BUSY
    jr nz, .loop

    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, .loop
    dec b
    jr nz, .loop
    ret

SECTION "VRAM Small Memory Copy", ROM0
; Waits for VRAM access before copying data. Slightly faster than vmemcopy with
; less setup, but can only copy 256 bytes at a time.
; @ c:  length
; @ de: destination
; @ hl: source
VRAMCopySmall::
    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, VRAMCopySmall
    ret

SECTION "VRAM Memory Set", ROM0
; Waits for VRAM access before setting data.
; @ d:  source (is preserved)
; @ bc: length
; @ hl: destination
VRAMSet::
    inc b
    inc c
    jr .decCounter
.loadByte
    ldh a, [rSTAT]
    and STATF_BUSY
    jr nz, .loadByte

    ld a, d
    ld [hli], a
.decCounter
    dec c
    jr nz, .loadByte
    dec b
    jr nz, .loadByte
    ret