
INCLUDE "include/banks.inc"
INCLUDE "include/bool.inc"
INCLUDE "include/directions.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/tiles.inc"

; Entities are stored in wEntityArray, which includes a 2-byte pointer to the
; entity's data, and then additional info, listed in entities.inc

SECTION "Entity Bank", ROM0

; Loops through the entity array, calling any script it finds
HandleEntities::

    call HandlePlayers

    ; loop through entity array
    ; bc: offset of current entity
    ld bc, $0000
    jr .skip
.loop
    ld a, sizeof_Entity
    add_r16_a b, c
    ld a, b
    cp a, high(sizeof_Entity * MAX_ENTITIES)
    jr nz, .skip ; Skip if there's no match
    ld a, c
    cp a, low(sizeof_Entity * MAX_ENTITIES)
    ret z ; Return if we've reached the end of the array
.skip
    ld hl, wEntityArray
    add hl, bc ; Apply the entity offset

    ; Check for entity
    ld a, [hli] ; Load the first byte of the entity
    and a, a ; If the first byte is 0, skip
    jr z, .loop
    ; Load entity constants
    ld l, [hl]  ; Finish loading the entity definition
    ld h, a ; Restore the Script Pointer
    ; Load entity Script
    ld a, [hli] ; Load bank of script
    swap_bank
    ld a, [hli] ; Load the first byte of the entity script
    ld h, [hl]  ; Finish loading the entity script
    ld l, a
    ; Run Entity Script Logic
    push bc ; Save the offset
    rst _hl_ ; Call the entity's script. It may use `c` to find it's data
    pop bc
    jr .loop

RenderEntities::
    call RenderPlayers
    ; loop through entity array
    ; c: offset of current entity !!! MUST NOT CHANGE C !!!
    ; @OPTIMIZE: This needlessly uses a 16-bit index. The entity array should never be so large.
    ; It previously used c alone, and may be reverted later.
    ld bc, $0000
    jr .skip
.loop
    ld a, sizeof_Entity
    add_r16_a b, c
    ld a, b
    cp a, high(sizeof_Entity * MAX_ENTITIES)
    jr nz, .skip ; Skip if there's no match
    ld a, c
    cp a, low(sizeof_Entity * MAX_ENTITIES)
    ret z ; Return if we've reached the end of the array
.skip
    ld hl, wEntityArray
    add hl, bc ; Apply the entity offset

    ; Check for entity
    ld a, [hl] ; Load the first byte of the entity
    and a, a ; If the first byte is 0, skip
    jr z, .loop
    push bc ; Save the offset
    call RenderMetasprite
    pop bc
    jr .loop

; Loads a script into wEntityArray if space is available. The Script must initiallize other vars.
; @ b:  World X position
; @ c:  World Y position
; @ de: Entity Script (BIG ENDIAN!)
; @ Preserves all input, returns Entity_YVel in `hl`
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
; @ hl: Entity Structure Origin
RenderMetasprite::
    ; Seek to position
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

BOUNDING_BOX_X EQU 6 ; A bit smaller than 16*16, because that feel/looks better.
BOUNDING_BOX_Y EQU 6

; Expanded version of MoveAndSlide which performs corner checks and only
; collides with TILEDATA_COLLISION, rather than all excluded tiles.
; @ hl: pointer to Entity. Returns Entity_YPos
PlayerMoveAndSlide::
.xMovement
    ; Seek to X Velocity
    ld a, Entity_XVel - Entity_DataPointer
    add a, l
    ld l, a
    ld c, [hl] ; C contains X Velocity
    ; Seek to YPosition
    ld a, Entity_YPos - Entity_XVel
    add a, l
    ld l, a
    SeekAssert Entity_YPos, Entity_XPos, 1
    ld a, [hli]
    ld b, a ; Save the Y Pos for later
    ld a, c
    add a, [hl] ; Add the XPos to the XVel
    ld d, a
    bit 7, c ; Check whether c is negative.
    jr nz, .xNeg
.xPos
    add a, BOUNDING_BOX_X ; offset by the Bounding box
    jr .xCheckCollision
.xNeg
    add a, -BOUNDING_BOX_X
.xCheckCollision
    ld c, a
    push de ; Save our target Location (d). Using ram may be better here.
    push hl ; Save our struct pointer
    push bc ; And save our test position, incase we need to slide around a corner.
    call LookupMapData
    ld a, [hl]
    cp a, TILEDATA_COLLISION
    pop bc
    pop hl
    pop de
    jr z, .yMovement ; Is there data here? Don't move.
    ; Handle movement
    ld a, d
    ld [hl], a ; Update X Pos. 
    ; Check for corners. 
    ; This is only really needed for the players and 
    ; could be avoided for others to save *lots* of time
.xTopCornerCheck
    push hl ; These two need to be saved. D is no longer important
    push bc
    ld a, b
    add a, BOUNDING_BOX_Y
    ld b, a
    call LookupMapData
    ld a, [hl]
    pop bc
    pop hl
    cp a, TILEDATA_COLLISION; Is there a wall on the corner?
    jr nz, .xBottomCornerCheck 
    inc l
    dec [hl] ; Slide out
    dec l
    jr .yMovement
.xBottomCornerCheck
    push hl ; We no longer need to preserve bc.
    ld a, b
    sub a, BOUNDING_BOX_Y
    ld b, a
    call LookupMapData
    ld a, [hl]
    pop hl
    cp a, TILEDATA_COLLISION; Is there a wall on the corner?
    jr nz, .yMovement
    inc l
    inc [hl] ; Slide out
    dec l
    
; WARNING!!! This is a disgusting copy/paste rather than a loop.
.yMovement
    SeekAssert Entity_XPos, Entity_YVel, 1
    inc l ; Seek to YVel
    SeekAssert Entity_YVel, Entity_XPos, -1
    ld a, [hld] ; Seek to XPos
    ld b, a ; B contains Y Velocity
    SeekAssert Entity_XPos, Entity_YPos, -1
    ld a, [hld] ; Seek to YPos
    ld c, a ; Save the XPos for later
    ld a, b
    add a, [hl] ; Add the YPos to the YVel
    ld d, a
    bit 7, b ; Check whether b is negative.
    jr nz, .yNeg
.yPos
    add a, BOUNDING_BOX_Y ; offset by the Bounding box
    jr .yCheckCollision
.yNeg
    add a, -BOUNDING_BOX_Y
.yCheckCollision
    ld b, a
    push de ; Save our target Location (d). Using ram may be better here.
    push hl ; Save our struct pointer
    push bc
    call LookupMapData
    ld a, [hl]
    cp a, TILEDATA_COLLISION
    pop bc
    pop hl
    pop de
    ret z ; Is there data here? Don't move.
    ld [hl], d ; Update Y Pos.
    ; Due to what some might call a bug, I only need to check one corner here.
    ; TODO: Make it check both.
.yLeftCornerCheck
    push hl ; We no longer need to preserve bc.
    ld a, c
    sub a, BOUNDING_BOX_X
    ld c, a
    call LookupMapData
    ld a, [hl]
    pop hl
    cp a, TILEDATA_COLLISION; Is there a wall on the corner?
    ret nz
    inc l
    inc [hl] ; Slide out
    dec l
    ret

; Move the Entity based on its Velocity. Slide along collision.
; @ hl: pointer to Entity. Returns Entity_YPos
MoveAndSlide::
    .xMovement
        ; Seek to X Velocity
        ld a, Entity_XVel - Entity_DataPointer
        add a, l
        ld l, a
        ld c, [hl] ; C contains X Velocity
        ; Seek to YPosition
        ld a, Entity_YPos - Entity_XVel
        add a, l
        ld l, a
        SeekAssert Entity_YPos, Entity_XPos, 1
        ld a, [hli]
        ld b, a ; Save the Y Pos for later
        ld a, c
        add a, [hl] ; Add the XPos to the XVel
        ld d, a
        bit 7, c ; Check whether c is negative.
        jr nz, .xNeg
    .xPos
        add a, BOUNDING_BOX_X ; offset by the Bounding box
        jr .xCheckCollision
    .xNeg
        add a, -BOUNDING_BOX_X
    .xCheckCollision
        ld c, a
        push de ; Save our target Location (d). Using ram may be better here.
        push hl ; Save our struct pointer
        push bc ; And save our test position, incase we need to slide around a corner.
        call LookupMapData
        ld a, [hl]
        dec a ; Skip 0
        cp a, TILEDATA_ENTITY_WALL_MAX
        pop bc
        pop hl
        pop de
        jr c, .yMovement ; Is there data here? Don't move.
        ; Handle movement
        ld a, d
        ld [hl], a ; Update X Pos. 
    .yMovement
        SeekAssert Entity_XPos, Entity_YVel, 1
        inc l ; Seek to YVel
        SeekAssert Entity_YVel, Entity_XPos, -1
        ld a, [hld] ; Seek to XPos
        ld b, a ; B contains Y Velocity
        SeekAssert Entity_XPos, Entity_YPos, -1
        ld a, [hld] ; Seek to YPos
        ld c, a ; Save the XPos for later
        ld a, b
        add a, [hl] ; Add the YPos to the YVel
        ld d, a
        bit 7, b ; Check whether b is negative.
        jr nz, .yNeg
    .yPos
        add a, BOUNDING_BOX_Y ; offset by the Bounding box
        jr .yCheckCollision
    .yNeg
        add a, -BOUNDING_BOX_Y
    .yCheckCollision
        ld b, a
        push de ; Save our target Location (d). Using ram may be better here.
        push hl ; Save our struct pointer
        push bc
        call LookupMapData
        ld a, [hl]
        dec a ; Skip 0
        cp a, TILEDATA_ENTITY_WALL_MAX
        pop bc
        pop hl
        pop de
        ret c ; Is there data here? Don't move.
        ld [hl], d ; Update Y Pos.
        ret

; Move the Entity based on its Velocity. Ignore Collision
; @ hl: pointer to Entity. Returns Entity_YPos
MoveNoClip::
    ld a, Entity_XVel
    add a, l
    ld l, a
    ld a, [hld] ; store XVel
    ld e, a
    ld a, [hld] ; Store YVel
    ld d, a
    ld a, [hl] ; Load and offset XPos
    add a, e
    ld [hld], a
    ld a, [hl] ; Load and offset YPos
    add a, d
    ld [hl], a
    ret


; Locates a given position in the map data and returns it in HL. Destroys all
; registers.
; @ b:  Y position
; @ c:  X position
LookupMapData::

    ; This is weird. 
    ; I don't have the time or care to look into it, but the X and Y need an offset. 
    ; Maybe just a result of my weird method of multiplication and division?
    ld a, b
    sub a, 16
    ld b, a

    ; This *is* neccassary. Sprites cannot be centered, so lets correct that a bit.
    ; Partially why I don't mind leaving this part in, though dec c would be faster.
    ld a, c
    sub a, 9 
    ld c, a

    ld hl, wMapData
    ; X translation (255 -> 16)
    ld a, c
    swap a ; a / 16 (sort of...)
    and a, %00001111 ; Mask out the upper bits
    add a, l
    ld l, a ; Offset map data by X. Lower byte is safe to use.
    ; Y translation (255 -> 16 * 16 or 256 ! )
    ld a, b
    and a, %11110000 ; We do need to mask out a bit...s
    add_r16_a h, l
    ret

; Check if the entity pointed to by `hl` collides with the position `de`.
; Preserves bc, returns `$0000` in `hl` if no collision is found.
; @ hl: Target Entity Pointer
; @ de: Check Position (Y, X)
CheckEntityCollision::
    inc l
    inc l
    ld a, [hli] ; Load YPos
    sub a, d ; Find the difference
    abs_a
    cp a, ENTITY_DETECTION_SIZE
    jr nc, .retFail
    ld a, [hld] ; Load X
    sub a, e
    abs_a
    cp a, ENTITY_DETECTION_SIZE
    jr nc, .retFail
    dec l
    dec l ; Return to origin
    ret
.retFail
    ld hl, $0000
    ret

; Returns The index of the first entity to collide with a location in bc. 
; If a returns FALSE, no entity was found.
; @ d:  Y position
; @ e:  X position
; @ bc: Source entity Index
DetectEntity::
    push bc
    ld bc, $0000
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
    jr nz, .continue ; Return if we've reached the end of the array 
    pop bc ; throw away source index.
    xor a, a ; ld a, FALSE
    ret 
.continue
    ld b, h
    ld c, l
.skip
    ld hl, wEntityArray
    add hl, bc ; Apply the entity offset

    ld a, [hli] ; Load the first byte of the entity
    and a, a ; If the first byte is 0, skip
    jr z, .loop
    ; Lets see if that entity collides with us!
    inc l
    ; Y time
    ld a, [hli] ; Load the YPos
    sub a, d ; Find the difference between the two.
    ; abs
    bit 7, a
    jr z, .absSkipY
    cpl 
    inc a
.absSkipY
    ; let's compare. c is >
    cp a, ENTITY_DETECTION_SIZE
    jr nc, .loop ; If the distance is greater than ENTITY_DETECTION_SIZE, check the next one.
    ; X time
    ld a, [hl] ; Load the XPos
    sub a, e ; Find the difference between the two.
    ; abs
    bit 7, a
    jr z, .absSkipX
    cpl
    inc a
.absSkipX
    ; let's compare. c is >
    cp a, ENTITY_DETECTION_SIZE
    jr nc, .loop ; If the distance is greater than ENTITY_DETECTION_SIZE, check the next one.
    pop hl ; Have we just found ourselves? (This is collecting the earlier push bc)
    ld a, l ; Low byte is more likely to be different
    cp a, c
    jr nz, .return
    ld a, h
    cp a, b
    jr nz, .return
    push bc
    jr .loop
.return
    ld a, TRUE
    ret

; Find the angle to `de` from `hl`. 
; Returns a normalized (0 or 2) vector in `hl` 
; (2 is used because it's a more comman value and takes nothing extra to load)
CalculateKnockback::
REPT 2
    srl d
    srl e
    srl h
    srl l
ENDR
.checkY
    ld a, d
    cp a, h
    jr z, .yEqu
    jr c, .yNeg
    ;jr nc, .yPos (fallthrough)
.yPos
    ld a, 2
    jr .checkX
.yEqu
    xor a, a
    jr .checkX
.yNeg
    ld a, -2
.checkX
    ld h, a
    ld a, e
    cp a, l
    jr z, .xEqu
    jr c, .xNeg
    ;jr nc, .xPos (fallthrough)
.xPos
    ld a, 2
    jr .return
.xEqu
    xor a, a
    jr .return
.xNeg
    ld a, -2
.return
    ld l, a
    ret

SECTION "Entity Array", WRAM0, ALIGN[$08] ; Align with $00 so that we can use unsafe struct seeking
wEntityArray::
    ; define an array of `MAX_ENTITIES` Entities, each named wEntityX
    dstructs MAX_ENTITIES * 3, Entity, wEntity

SECTION UNION "Volatile", HRAM
hRenderByte: ; currently stores the entity's invtimer to find out if it should blink
    ds 1