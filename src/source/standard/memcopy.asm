SECTION "Memory Copy", ROM0

; Copies a certain amount of bytes from one location to another
; @ arguments:
; @ bc: length
; @ de: destination
; @ hl: source
MemCopy:
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