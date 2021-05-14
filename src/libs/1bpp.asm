INCLUDE "include/hardware.inc"

SECTION "One Bit Per Pixel", ROM0

; Equivalent to memcopy_small, but copies each byte twice for 1bpp graphics.
; @  c: length
; @ de: destination
; @ hl: source
Unpack1bpp::
	ld a, [hli]
	ld [de], a
	inc de
	ld [de], a
	inc de
	dec c
	jr nz, Unpack1bpp
	ret

; Switches banks and calls Unpack1bpp, switching back to hCurrent bank when 
; finished.
; @ a:  target bank
; @ c:  length
; @ de: destination
; @ hl: source
Unback1bppBanked::
	ld [rROMB0], a
	call Unpack1bpp
	ldh a, [hCurrentBank]
	ld [rROMB0], a
	ret

; Complements each byte, inverting the resulting graphics.
; @  c: length
; @ de: destination
; @ hl: source
Complement1bpp::
	ld a, [hli]
    cpl
	ld [de], a
	inc de
	ld [de], a
	inc de
	dec c
	jr nz, Complement1bpp
	ret