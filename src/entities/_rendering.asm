INCLUDE "banks.inc"
INCLUDE "entity.inc"
INCLUDE "graphics.inc"

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
    ; Seek to Entity metasprites.
    ld a, EntityDefinition_Metasprites - EntityDefinition_Logic
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; Load the metasprite pointer.
    ld a, [hli] ; Swap to the metasprites' bank
    rst SwapBank
    ld a, [hli] ; Load low
    ld h, [hl] ; load high
    ld l, a
    ld a, d ; Load frame
    add a, a ; frame * 2
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ld a, [hli]
    ld h, [hl]
    ld l, a

; This label is used to render a metasprite at an absolute location, rather than
; considering any entity information. Make sure to set `hRenderByte` to zero!
; @ bc: Position (y, x)
; @ hl: Metasprite pointer
.absolute::
    ldh a, [hOAMIndex]
    ld e, a
    ld d, HIGH(wShadowOAM)

    ; Load and offset Y
    ld a, [hli]
.pushSprite ; We can skip that load, since a loop will have already done it.
    push bc
    add a, b
    ld b, a
    ldh a, [hSCYBuffer]
    cpl
    add a, b
    ld [de], a
    inc de
    ; Load and offset X
    ld a, [hli]
    add a, c
    ld c, a
    ldh a, [hSCXBuffer]
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

; Uses an entity's direction to offset its metasprites suring rendering.
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

SECTION "Render Info", HRAM
hRenderByte:: ; currently stores the entity's invtimer to find out if it should blink
    ds 1