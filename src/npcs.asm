INCLUDE "npc.inc"

; TODO: NPCs should look at the player when talked to.

SECTION "NPC Logic", ROM0

RenderNPCs::
    ; Reset NPC index
    xor a, a
    ldh [hNPCArrayIndex], a
    ; Reset rendering info as well.
    ldh [hRenderByte], a
.loop
    ASSERT LOW(wNPCArray) == 0
    ld e, a
    ld d, HIGH(wNPCArray)

    ; Load metasprite pointer
    ld a, [de] ; Bank
    ; If the bank is 0, assume no entity
    and a, a
    jr z, .next

    rst SwapBank
    inc e

    ; Load pointer
    ld a, [de]
    ld l, a
    inc e
    ld a, [de]
    ld h, a

    ; Load direction
    inc e
    ld a, [de]
    inc e
    add a, a ; a * 2
    ; Offset the metasprite lookup by direction
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

    ; Grab sprite
    ld a, [hli]
    ld h, [hl]
    ld l, a

    ; Load position
    ; Start with loading X
    ld a, [de]
    and a, $0F
    ; Positions go up to 16, so multiply to get to 256
    swap a ; a * 16
    add a, 17 ; Positions need a bit of an offset to snap to tiles
    ld c, a
    ; Now load Y
    ld a, [de]
    and a, $F0
    add a, 25 ; Positions need a bit of an offset to snap to tiles
    ; No swap is needed this time.
    ld b, a

    ; Render and loop.
    call RenderMetasprite.absolute

.next
    ; Increment the NPC index
    ldh a, [hNPCArrayIndex]
    add a, sizeof_NPC
    ; If we've gone past 4 entities it's time to return
    cp a, NB_NPCS * sizeof_NPC
    ret z
    ; Otherwise save index and loop.
    ldh [hNPCArrayIndex], a
    jr .loop


SECTION "NPC Array", WRAM0, ALIGN[8]

wNPCArray::
    dstructs NB_NPCS, NPC, wNPC

SECTION UNION "Volatile", HRAM

hNPCArrayIndex:
    ds 1