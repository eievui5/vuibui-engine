
include "include/hardware.inc"
include "include/defines.inc"

SECTION "OAM DMA routine", ROM0
OAMDMA::
	ldh [rDMA], a
	ld a, MAXIMUM_SPRITES
.wait
	dec a
	jr nz, .wait
	ret
.end::


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