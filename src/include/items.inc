IF !DEF(ITEMS_INC)
DEF ITEMS_INC EQU 1

INCLUDE "structs.inc"

DEF NB_COLLECTABLES EQU 4
DEF MAX_BOUNCE EQU 10

	struct CollectableData
		; Run this function upon collecting the item.
		words 1, CollectionFunction
		; This is a flexible array for storing the collectable's metasprite.
		dunion Metasprite
	end_struct

	struct Collectable
		; Constant data, such as the function to run upon collection, and 4 tile
		; indices used for rendering.
		words 1, Data
		; A short timer to give items a "bounce" effect upon being created (configurable)
		bytes 1, Lifetime
		; Position
		bytes 1, YPos
		bytes 1, XPos
		; Set this flag upon collecting the item. Ignore if 0.
		bytes 1, CollectionFlag
		; Align the struct save to a power of 2 (8).
		bytes 2, AlignmentPadding
	end_struct

ENDC