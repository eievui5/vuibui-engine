
SECTION "Overwrite Bytes", ROM0

; Overwrites a certain amount of bytes with a single byte.
; @ arguments:
; @  a: source (is preserved)
; @ bc: length
; @ hl: destination
MemOver::
	inc b
	inc c
	jr .decCounter
.loadByte
	ld [hli],a
.decCounter
	dec c
	jr nz, .loadByte
	dec b
	jr nz, .loadByte
	ret

SECTION "Memory Copy", ROM0

; Copies a certain amount of bytes from one location to another
; @ arguments:
; @ bc: length
; @ de: destination
; @ hl: source
MemCopy::
	inc b
	inc c
	jr .decCounter
.loadByte
    ld a, [hli]
	ld [de], a
    inc de
.decCounter
	dec c
	jr nz, .loadByte
	dec b
	jr nz, .loadByte
	ret

SECTION "Jump Table", ROM0

; Jumps the the `a`th pointer. 128 pointers max.
; @ a: Jump Offset
HandleJumpTable::
	; Restore Pointer to jump table
	pop hl
	; a * 2 (pointers are 2 bytes!)
	add a, a
	; add hl, a
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
	; Load pointer into hl
	ld a, [hli] ; low byte
	ld h, [hl] ; high byte
	ld l, a
	; Now jump!
	jp hl

SECTION "Call HL", ROM0

_hl_::
    jp hl