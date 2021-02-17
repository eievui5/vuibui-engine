include "include/hardware.inc"
include "include/defines.inc"

; Entities are stored in wEntityArray, which includes a 2-byte pointer to the
; entity's data, and then additional info, listed in defines.inc

; Used to find an entity's data, storing it in hl. Starts on X_POS
FindEntity: MACRO
    ld hl, wEntityArray
    add hl, bc
    inc hl ; skip the script!
    inc hl
ENDM


SECTION "Entity Bank", ROMX
; Loops through the entity array, calling any script it finds
HandleEntities::
    ; loop through entity array
    ; c: offset of current entity !!! MUST NOT CHANGE C !!!
    ; @OPTIMIZE: This needlessly uses a 16-bit index. The entity array should never be so large.
    ; It previously used c alone, and may be reverted later.
    ld b, 0
    ld c, 0
    jr .skip
.loop
    ; Increment the array index
    ld h, b ; Swap over to hl for some math
    ld l, c
    ld b, 0
    ld c, ENTITY_SIZE
    add hl, bc
    ld a, h
    cp a, high(ENTITY_SIZE * MAX_ENTITIES)
    jr nz, .continue ; Skip if there's no match
    ld a, l
    cp a, low(ENTITY_SIZE * MAX_ENTITIES)
    ret z ; Return if we've reached the end of the array
.continue
    ld b, h
    ld c, l
.skip
    ld hl, wEntityArray
    add hl, bc ; Apply the entity offset

    ld a, [hli] ; Load the first byte of the entity
    cp a, 0 ; If the first byte is 0, skip
    jr z, .loop
    ld d, a ; Store the first byte for later
    ld a, [hl]  ; Finish loading the entity script
    ld h, d ; Restore the Script Pointer
    ld l, a
    push bc ; Save the offset
    call _hl_ ; Call the entity's script. It may use `c` to find it's data
    pop bc
    jr .loop

; #################################################
; ###                 Entities                  ###
; #################################################

Player::
    FindEntity
    ldh a, [hCurrentKeys]
.moveUp
    bit PADB_UP, a
    jr z, .moveDown
    dec [hl] ; If up is pressed move up
.moveDown
    bit PADB_DOWN, a
    jr z, .moveRight
    inc [hl] ; If down is pressed move down
.moveRight
    inc hl
    bit PADB_RIGHT, a
    jr z, .moveLeft
    inc [hl] ; If right is pressed move right
.moveLeft
    bit PADB_LEFT, a
    jr z, .render
    dec [hl] ; If left is pressed move left
.render
    FindEntity
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a
    ld hl, TestMetasprite
    jp RenderMetasprite

; Renders a given metasprite at a given location
; @ arguments:
; @ b:  Screen X position
; @ c:  Screen Y position
; @ hl: Metasprite
; @ TODO: Add support for >1 sprite, using the METASPRITE_END byte
RenderMetasprite:
    push hl 
    ; Find Available Shadow OAM
    ldh a, [hOAMIndex]
    ld d, 0 
    ld e, a 
    ld hl, wShadowOAM
    add hl, de
    ld d, h
    ld e, l
    pop hl
    ; Load and offset Y
    ld a, [hli]
.pushSprite ; We can skip that load, since a loop will have already done it.
    add a, b
    ld [de], a
    inc de
    ; Load and offset X
    ld a, [hli]
    add a, c
    ld [de], a
    inc de
    ; Load tile
    ld a, [hli]
    ld [de], a
    inc de
    ; Load attributes.
    ld a, [hli]
    ld [de], a
    inc de
    ; Update OAM Index
    ldh a, [hOAMIndex]
    add a, 4
    ldh [hOAMIndex], a
    ; Check for End byte
    ld a, [hli]
    cp a, METASPRITE_END
    jr nz, .pushSprite
    ret

SECTION "Entity Array", WRAM0 
wEntityArray::
    ds ENTITY_SIZE * MAX_ENTITIES
