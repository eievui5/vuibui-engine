
;
; 1BPP graphics functions.
;
; Copyright 2021, Eievui
;
; This software is provided 'as-is', without any express or implied
; warranty.  In no event will the authors be held liable for any damages
; arising from the use of this software.
; 
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
; 
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.
;

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

LCDComplement1bpp::
        ldh a, [rSTAT]
        and STATF_BUSY
        jr nz, LCDComplement1bpp
    ld a, [hli]
    cpl
    ld [de], a
    inc de
    ld [de], a
    inc de
    dec c
    jr nz, LCDComplement1bpp
    ret