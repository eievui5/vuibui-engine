
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

SECTION "Call HL", ROM0

_hl_::
    jp hl