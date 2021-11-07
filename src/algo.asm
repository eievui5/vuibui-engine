SECTION "Interpolate 8-bit", ROM0
; Unsigned interpolation towards an 8 bit value.
; @in  b: Current value.
; @in  c: Target value
; @in  d: Interpolation factor.
; @out b: Resulting value.
Interp8::
	; Don't interpolate if you already reached the target.
	ld a, b
	cp a, c
	ret z
	; Determine the direction of interpolation.
	ld a, c
	sub a, b
	bit 7, a
	jr z, :+
	ld a, d
	cpl
	inc a
	ld d, a
:
	; Add the interpolation factor to the current value.
	ld a, b
	add a, d
	ld b, a
	; Check if the value reached its target or overflowed.
	cp a, c
	ret z
	; A now contains the different between the value and its target.
	; If this is smaller than the interpolation factor, clamp the value and
	; return.
	; if (abs(target - current) < abs(factor)) return target else return current;
	ld a, c
	sub a, b
	; abs(target - current)
	bit 7, a
	jr z, :+
	cpl
	inc a
:
	ld e, a ; Store the difference in c.
	; abs(factor)
	ld a, d
	bit 7, a
	jr z, :+
	cpl
	inc a
:
	ld d, a
	ld a, e
	; abs(target - current) < abs(factor)
	cp a, d
	ret nc ; if abs(target - current) >= abs(factor), return current
	; else, return the target value
	ld b, c
	ret
