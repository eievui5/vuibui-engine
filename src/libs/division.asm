/* (currently unused)
SECTION "Divide", ROM0

; Divides `a` by `b`, returning the result in `c`.
; Division is very slow! This function can range from 16 - 644 cycles, and should be avoided if b is known.
; Being unrolled, this function is 97 bytes.
; @ `(a / b) = c (remainder: a)`
divide::
	dec b ; if b == 1
	jr z, .one ; skip processing
	inc b ; if b == 0
	jr z, .error ; return 0 (and break)
	; 2x Check
	ld c, a
	ld a, 127
	cp a, b ; is 127 < b?
	ld a, c
	ld c, 0
	jr c, .loop1 ; if b is too large to multiply, skip the 2 loop.
	sla b ; b * 2
	; 4x Check
	ld c, a
	ld a, 127
	cp a, b ; is 127 < b?
	ld a, c
	ld c, 0
	jr c, .loop2 ; if b is too large to multiply, skip the 4 loop.
	sla b ; b * 4
	; 8x Check
	ld c, a
	ld a, 127
	cp a, b ; is 127 < b?
	ld a, c
	ld c, 0
	jr c, .loop4 ; if b is too large to multiply, skip the 8 loop.
	sla b ; b * 8
	; 16x Check
	ld c, a
	ld a, 127
	cp a, b ; is 127 < b?
	ld a, c
	ld c, 0
	jr c, .loop8 ; if b is too large to multiply, skip the 8 loop.
	sla b ; b * 16
.loop16
	inc c
	inc c
	sub a, b
	jr nc, .loop16
	add a, b
	dec c
	dec c
	sra b
.loop8
	inc c
	inc c
	sub a, b
	jr nc, .loop8
	add a, b
	dec c
	dec c
	sra b
.loop4
	inc c
	inc c
	sub a, b
	jr nc, .loop4
	add a, b
	dec c
	dec c
	sra b
.loop2
	inc c
	inc c
	sub a, b
	jr nc, .loop2
	add a, b
	dec c
	dec c
	sra b
.loop1
	inc c
	sub a, b
	jr nc, .loop1
	add a, b
	dec c
	ret
.error
	xor a, a
	ld b, b
.one
	ret
*/