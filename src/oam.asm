
include "include/hardware.inc"
include "include/graphics.inc"

SECTION "OAM DMA routine", ROM0
OAMDMA::
	ldh [rDMA], a
	ld a, MAXIMUM_SPRITES
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
	ds MAXIMUM_SPRITES * 4
.end::


SECTION "OAM DMA", HRAM
; Location of the copied OAM DMA Routine
hOAMDMA::
	ds OAMDMA.end - OAMDMA


SECTION "OAM Index", HRAM
; Used to order sprites in shadow OAM
hOAMIndex:: ds 1