INCLUDE "include/defines.inc"

SECTION UNION "Shadow OAM", WRAM0,ALIGN[8]

wShadowOAM::
	ds MAXIMUM_SPRITES * 4

SECTION "Input Buffer", HRAM

hInputBuffer::
	ds $01