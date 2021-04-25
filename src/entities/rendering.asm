INCLUDE "include/banks.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/graphics.inc"

; Renderers expect `bc` as a struct offset, as in regular logic.
; Since metasprites are stored in ROMX, common rendering functions are located
; in ROM0. Rendering functions *can* work in ROMX, as long as they are in the
; same bank as the metasprites they intend to render.

SECTION "Common Rendering Logic", ROM0

; Basic metasprite rendering. Please use `RenderMetasprite.native` for
; regular entities, and `RenderMetasprite.foreign` for any entities outside
; the standard entity array.
; @ .native Input:
; @ bc: Entity Array offset
; @ .foreign Input:
; @ hl: Entity Structure Pointer
RenderMetasprite::
.native::
    ld hl, wEntityArray
    add hl, bc
.foreign::
    ASSERT Entity_DataPointer + 2 == Entity_YPos
    inc hl
    inc hl
    ; Load position
    ld a, [hli]
    ld b, a
    ld c, [hl]
    ; Seek from XPos to Frame and store it for later.
    ld a, Entity_Frame - Entity_XPos
    add a, l
    ld l, a
    ld d, [hl]
.afterFrameHook
    ; Seek to the timer from the frame and store it for later.
    ld a, Entity_InvTimer - Entity_Frame
    add a, l
    ld l, a
    ld a, [hl]
    ldh [hRenderByte], a ; Store timer here.
    ; Seek from the Invincibility Timer back to the Data Pointer.
    ld a, Entity_DataPointer - Entity_InvTimer
    add a, l
    ld l, a
    ld a, [hli]
    ld l, [hl]
    ld h, a
    ; Seek to Entity data.
    ASSERT EntityDefinition_Logic + 3 == EntityDefinition_Metasprites
    inc hl ; Skip logic bank
    inc hl ; skip logic low
    inc hl ; skip logic high
    ; Load the metasprite pointer.
    ld a, [hli] ; Swap to the metasprites' bank
    swap_bank
    ld a, [hli] ; Load low
    ld h, [hl] ; load high
    ld l, a
    ld a, d ; Load frame
    add a, a ; frame * 2
    add_r16_a h, l
    ld a, [hli]
    ld h, [hl]
    ld l, a

    ; At this point:
    ; bc - Position (x, y)
    ; hl - Metasprite pointer
    ; Find Available Shadow OAM
    ldh a, [hOAMIndex]
    ld de, wShadowOAM
    add_r16_a d, e
    ; Load and offset Y
    ld a, [hli]
    .pushSprite ; We can skip that load, since a loop will have already done it.
    push bc
    add a, b
    ld b, a
    ld a, [wSCYBuffer]
    cpl
    add a, b
    ld [de], a
    inc de
    ; Load and offset X
    ld a, [hli]
    add a, c
    ld c, a
    ld a, [wSCXBuffer]
    cpl
    add a, c
    ld [de], a
    inc de
    ; Load tile
    ld a, [hli]
    ld [de], a
    inc de
    ; Load attributes.
    ld a, [hRenderByte]
    bit 2, a ; Every 8/60 second, set pallet!
    ld a, [hl]
    jr z, .skipFlip
        and a, %11101000 ; Mask out all palettes
        or a, OAMF_PAL1 | DEFAULT_INV
    .skipFlip
    ld [de], a
    inc de
    inc hl
    ; Update OAM Index
    ldh a, [hOAMIndex]
    add a, 4
    ldh [hOAMIndex], a
    ; Check for End byte
    pop bc
    ld a, [hli]
    cp a, METASPRITE_END
    jr nz, .pushSprite
    ret

RenderMetaspriteDirection::
.native::
    ld hl, wEntityArray
    add hl, bc
.foreign::
    ASSERT Entity_DataPointer + 2 == Entity_YPos
    inc hl
    inc hl
    ; Load position
    ld a, [hli]
    ld b, a
    ld c, [hl]
    ; Seek from XPos to Direction and Frame and store them for later.
    ld a, Entity_Direction - Entity_XPos
    add a, l
    ld l, a
    ld a, [hli] ; Load direction
    add a, [hl] ; add frame
    ld d, a ; Store for later.
    jr RenderMetasprite.afterFrameHook ; Jump back to the standard render function

SECTION UNION "Volatile", HRAM
hRenderByte: ; currently stores the entity's invtimer to find out if it should blink
    ds 1