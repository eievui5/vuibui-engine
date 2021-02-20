include "include/defines.inc"
include "include/entities.inc"
include "include/hardware.inc"
include "include/macros.inc"

include "source/metasprites.asm"

; Entities are stored in wEntityArray, which includes a 2-byte pointer to the
; entity's data, and then additional info, listed in entities.inc

; Used to find an entity's data, storing it in hl. Starts on ENTITY_Y_OFF
FindEntity: MACRO
    ld hl, wEntityArray
    add hl, bc
    inc hl ; skip the script!
    inc hl
ENDM

 
; Destroys a script
; @ hl: Entity Script
KillEntity: MACRO 
    ld hl, wEntityArray
    add hl, bc
    xor a
    ld [hli], a
    ld [hli], a
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
    ld c, sizeof_Entity
    add hl, bc
    ld a, h
    cp a, high(sizeof_Entity * MAX_ENTITIES)
    jr nz, .continue ; Skip if there's no match
    ld a, l
    cp a, low(sizeof_Entity * MAX_ENTITIES)
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


; Loads a script into wEntityArray at a given location. The Script must initiallize other vars.
; @ b:  World X position
; @ c:  World Y position
; @ de: Entity Script
; @ Preserves all input, destroys hl and a
SpawnEntity::
    push bc
    push de
    ld d, MAX_ENTITIES + 1
    ld bc, sizeof_Entity
    ld hl, wEntityArray - sizeof_Entity
.loop
    dec d
    jr z, .break
    add hl, bc
    ld a, [hl]
    ; Check the first script byte. 
    ; Since all Entities exist off the main bank, this will never be $00
    cp a, $00
    jr nz, .loop ; if a == 0, loop
    pop de
    pop bc
    ld a, d
    ld [hli], a ; Load the first script byte.
    ld a, e
    ld [hli], a ; Load the second script byte
    ld a, c
    ld [hli], a ; Load the Y Position
    ld a, b
    ld [hli], a ; Load the X Position
    ; We can ignore the rest of these, since they *should* be overwritten by the entity constructor.
    ret
.break
    pop de ; Get rid of those stacked regs.
    pop bc
    ; Since spawning scripts may want to overwrite some stats, we let them know
    ; if the spawn failed using hl.
    ld hl, $0000 
    ret

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

; #################################################
; ###                 Entities                  ###
; #################################################

; Very Experimental Player Script !!!
; This should later be moved into it's own

; Flags:
; 0-1: Facing Direction
FACING_MASK EQU %00000011

Player:: 
    FindEntity
    push bc

; Timer handling
    StructSeekUnsafe l, Entity_YPos, Entity_Timer
    ld a, [hl] ; Load Timer
    inc a ; Step the timer
    ld c, a ; Save the timer for later.
    ld [hld], a

; Determine Facing Direction.
    ld a, [hl] ; Load Flags
    and a, FACING_MASK
    ld b, a
    push bc
    inc b
    ld de, OctaviaDown - $09 ; Down is offset 0, each metasprite is 9 bytes
.facingLoop
    ld a, $09
    add_r16_a d, e
    dec b
    jr nz, .facingLoop
    pop bc
    ; `de` is now a metasprite facing direction, which can be offset to find anything else.
    StructSeekUnsafe l, Entity_Flags, Entity_YPos

    ; b:  Facing Direction
    ; c:  Timer
    ; de: Metasprite pointer
    ; hl: Pointer to Y

    ldh a, [hCurrentKeys]
    cp a, $00
    jr z, .render ; Skip movement if there is none

.moveUp
    bit PADB_UP, a
    jr z, .moveDown
    dec [hl] ; If up is pressed move up
    ld b, 1 ; Face up
    jr .moveRight ; Skip down.

.moveDown
    bit PADB_DOWN, a
    jr z, .moveRight
    inc [hl] ; If down is pressed move down
    ld b, 0 ; Face down

.moveRight
    inc hl
    bit PADB_RIGHT, a
    jr z, .moveLeft
    inc [hl] ; If right is pressed move right
    ld b, 2 ; Face right
    jr .moveFinal ; Skip Left

.moveLeft
    bit PADB_LEFT, a
    jr z, .moveFinal
    dec [hl] ; If left is pressed move left
    ld b, 3 ; Face left

.moveFinal
; Store Facing dir
    StructSeekUnsafe l, Entity_XPos, Entity_Flags
    ld a, ~FACING_MASK
    and a, [hl] ; Mask out the old facing bits
    or a, b
    ld [hli], a ; Store the new flags
    bit 4, c
    jr nz, .collide
    ld a, 9 * 4 ; Size of metasprite * 4 directions
    add_r16_a d, e ; offset to the step location

.collide

.render
    pop bc
    FindEntity ; Find the entity again (slow!, please fix using something else!)
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a ; Load the X and Y
    ld h, d
    ld l, e ; Load the metasprite Pointer
    jp RenderMetasprite

SECTION "Entity Array", WRAM0, ALIGN[$00] ; Align with $00 so that we can use unsafe struct seeking
wEntityArray::
    ; define an array of `MAX_ENTITIES` Entities, each named wEntityX
    dstructs MAX_ENTITIES, Entity, wEntity