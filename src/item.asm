INCLUDE "graphics.inc"
INCLUDE "items.inc"

SECTION "Debug Collectable", ROM0
DebugCollectable::
	DW null

    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_DOWN_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_DOWN_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB METASPRITE_END

SECTION "Render Collectables", ROM0
; Render the active collectables and simulate their gravity.
RenderCollectables::
	ld hl, wCollectablesArray
.for
	; Skip the item if it has NULL data.
	ld a, [hli]
	or a, [hl]
	jr z, .next

	; Grab the data pointer while we're here in the struct.
	ld a, [hld]
	ld d, a
	ld a, [hli]
	ld e, a

	; Simulate gravity using lifetime.
	; Gravity starts negative and slowly increases until reaching a final value.
	inc l
	ld a, [hl]
	cp a, MAX_BOUNCE
	jr z, .render
	inc [hl]
	; Move to Y position and add gravity
	inc l
	sra a
	sra a
	jr nc, .noRound
	inc a
.noRound
	add a, [hl]
	ld [hld], a ; Go back down to re-use the following code.

.render
	inc l
	ld a, [hli]
	; Load new Y position into A
	ld b, a
	ld c, [hl]
	push hl
		ld h, d
		ld l, e
		; Skip collection function, now on flexibly-sized metasprite array.
		inc hl
		inc hl
		xor a, a
		ldh [hRenderByte], a
		call RenderMetasprite.absolute
	pop hl

.next
	; Align to the next struct.
	ld a, l
	ASSERT sizeof_Collectable == 8, "Collectable size must be a power of two for alignment."
	or a, sizeof_Collectable - 1
	ld l, a
	inc hl
	; Check for the end of the array
	cp a, LOW(wCollectablesArray + sizeof_Collectable * NB_COLLECTABLES) - 1
	jr nz, .for
	ret

SECTION "Spawn Collectable", ROM0
; Spawn a collectable at a given position. Be careful - this function simply
; does nothing upon failure.
; @in bc: Collectable data pointer.
; @in d:  Y Position
; @in e:  X Position
; @out hl: Pointer to Collectable_CollectionFlag. if l & %111 == 0, then the function failed.
SpawnCollectable::
	ld hl, wCollectablesArray
.for
	; Skip the item if it does not have NULL data.
	ld a, [hli]
	or a, [hl]
	jr nz, .next

	dec l
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, -MAX_BOUNCE
	ld [hli], a
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a
	ret

.next
	; Align to the next struct.
	ld a, l
	ASSERT sizeof_Collectable == 8, "Collectable size must be a power of two for alignment."
	or a, sizeof_Collectable - 1
	ld l, a
	inc hl
	; Check for the end of the array
	cp a, LOW(wCollectablesArray + sizeof_Collectable * NB_COLLECTABLES) - 1
	jr nz, .for
	ret

ASSERT sizeof_Collectable == 8, "Collectable size must be a power of two for alignment."
SECTION "Collectables Array", WRAM0, ALIGN[3]
wCollectablesArray::
	dstructs NB_COLLECTABLES, Collectable, wCollectable