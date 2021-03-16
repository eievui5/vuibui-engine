SECTION "Overwrite Bytes", ROM0

; Overwrites a certain amount of bytes with a single byte. Destination is offset
; by length, in case you want to overwrite with different values.
; @  a: source (is preserved)
; @ bc: length
; @ hl: destination
memset::
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

; Copies a certain amount of bytes from one location to another. Destination and
; source are both offset by length, in case you want to copy to or from multiple
; places.
; @ bc: length
; @ de: destination
; @ hl: source
memcopy::
	dec bc
	inc b
	inc c
  .loop:
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret

SECTION "Jump Table", ROM0

; Jumps the the `a`th pointer. 128 pointers max. Place pointers after the call
; using `dw`. This function is faster than a decrement table if there are 8 or
; more destinations, and is always smaller.
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

SECTION "Null Pointer Handler", ROM0[$0000]
null:
	nop
	nop
	rst crash

SECTION "Call HL", ROM0[$0008]
; Used to call the address pointed to by `hl`. Mapped to `rst $08` or `rst _hl_`
_hl_::
    jp hl

SECTION "Crash Handler", ROM0[$0038]
crash:
	ld d, d
	ld b, b
	halt