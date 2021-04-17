/* 1bpp.asm
    Functions related to loading and manipulating 1bpp graphics.

Functions:

    Unpack1bpp
        - Equivalent to memcopy_small, but copies each byte twice for 1bpp 
        graphics.
    
    Complement1bpp
        - Complements each byte, inverting the resulting graphics.

*/

SECTION "One Bit Per Pixel", ROM0

; Equivalent to memcopy_small, but copies each byte twice for 1bpp graphics.
; @  c: tiles
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

; Complements each byte, inverting the resulting graphics.
; @  c: tiles
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