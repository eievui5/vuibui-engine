
;
; Simple OAM DMA library.
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

SECTION "OAM DMA routine", ROM0
; Code for OAM DMA. Do not call this function directly; it must be copied to and
; run from HRAM (hOAMDMA).
OAMDMA::
	ldh [rDMA], a
	ld a, OAM_COUNT
.wait
	dec a
	jr nz, .wait
	ret
.end::

SECTION "Clear OAM", ROM0

; Reset OAM, wShadowOAM, and wOAMIndex to 0. Only use while VRAM is accessible!
ResetOAM::
    xor a, a
    ld c, wShadowOAM.end - wShadowOAM
    ld hl, _OAMRAM
    rst memset_small
; Reset wShadowOAM and wOAMIndex to 0.
CleanOAM::
    xor a, a
    ldh [hOAMIndex], a ; Reset the OAM index.
    ld c, wShadowOAM.end - wShadowOAM
    ld hl, wShadowOAM
    jp memset_small

SECTION UNION "Shadow OAM", WRAM0, ALIGN[8]
wShadowOAM::
	ds OAM_COUNT * 4
.end::


SECTION "OAM DMA", HRAM
; Copies Shadow OAM to OAM using OAM DMA.
; @ a - High byte of Shadow OAM
hOAMDMA::
	ds OAMDMA.end - OAMDMA


SECTION "OAM Index", HRAM
; Used to order sprites in shadow OAM
hOAMIndex:: ds 1