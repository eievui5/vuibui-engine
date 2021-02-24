
SECTION "Overwrite Bytes", ROM0

; Overwrites a certain amount of bytes with a single byte.
; @ arguments:
; @  a: source (is preserved)
; @ bc: length
; @ hl: destination
MemOver:
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