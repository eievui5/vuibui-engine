INCLUDE "entity.inc"
INCLUDE "graphics.inc"
INCLUDE "items.inc"
INCLUDE "scripting.inc"
INCLUDE "text.inc"

SECTION "Heart Container Collectable", ROM0
HeartContainerCollectable::
	DW .function

    DB -7 ; y
    DB -7 ; x
    DB TILE_HEART_LEFT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_BANK0 ; Flags

    DB -7 ; y
    DB 1  ; x
    DB TILE_HEART_RIGHT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_BANK0 ; Flags

    DB METASPRITE_END

.function
	ld a, [wActivePlayer]
	add a, LOW(wPlayerMaxHealth)
	ld l, a
	adc HIGH(wPlayerMaxHealth)
	sub a, l
	ld h, a
	inc [hl]
	inc [hl]
	ld b, [hl]

	ld a, [wActivePlayer]
	swap a
	add a, LOW(wPlayerArray + Entity_Health)
	ld l, a
	adc HIGH(wPlayerArray + Entity_Health)
	sub a, l
	ld h, a
	ld [hl], b
	ret

SECTION "Heart Container Tiles", ROMX
xGfxHeartContainer:: INCBIN "res/gfx/misc/heart_container.h.2bpp"
.end::