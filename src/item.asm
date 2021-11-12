INCLUDE "entity.inc"
INCLUDE "graphics.inc"
INCLUDE "items.inc"
INCLUDE "scripting.inc"
INCLUDE "text.inc"

SECTION "Debug Collectable", ROM0
DebugCollectable::
	DW .function

    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_DOWN_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_DOWN_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB METASPRITE_END

.function
	ld hl, wActiveScriptPointer
	xor a, a
	ld [hli], a
	ld a, LOW(.script)
	ld [hli], a
	ld [hl], HIGH(.script)
	ret

.script
	pause
	display_text .text
	end_script

.text
	say "You got the\n"
	say "item."
	end_text

SECTION "Detect Collectables", ROM0
DetectCollectables::
	ld hl, wCollectablesArray
.for
	; Skip the item if it has NULL data.
	ld a, [hli]
	or a, [hl]
	jr z, .next

	; Check if this item collides with the active player.
	ld a, [wActivePlayer]
	ASSERT sizeof_Entity == 16
	swap a ; a * 16
	add a, LOW(wPlayerArray + Entity_YPos)
	ld e, a
	adc a, HIGH(wPlayerArray + Entity_YPos)
	sub a, e
	ld d, a
	; Seek to YPos
	inc l ; Skip high byte.
	inc l ; Skip lifetime.
	; Get the absolute value of the distance between the objects and check if it
	; is below a certain value.
	ld a, [de]
	sub a, [hl]
	; abs(a)
	bit 7, a
	jr z, :+
	cpl
	inc a
:
	cp a, 8
	jr nc, .next

	; Now check X
	inc e
	inc l
	ld a, [de]
	sub a, [hl]
	; abs(a)
	bit 7, a
	jr z, :+
	cpl
	inc a
:
	cp a, 8
	jr nc, .next

	; The distance is under 8? Clear the item, run the collection function, and
	; exit.
	; Seek to flag byte and set if needed.
	inc l
	ld a, [hld]
	and a, a
	jr z, .noFlag
	push hl
		ld b, a
		ld hl, wBitfield
		call GetBitfieldMask
		; or to set.
		or a, [hl]
		ld [hl], a
	pop hl
.noFlag
	; Seek to high byte.
	dec l
	dec l
	dec l
	ld a, [hld]
	push hl
		ld l, [hl]
		ld h, a
		; deref the pointer we're caling.
		ld a, [hli]
		ld h, [hl]
		ld l, a
		rst CallHL
	pop hl
	; Now we have the base pointer to the item.
	xor a, a
	ld c, sizeof_Collectable
	rst MemSetSmall
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