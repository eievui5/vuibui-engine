INCLUDE "include/banks.inc"
INCLUDE "include/directions.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/tiledata.inc"

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
    ; Add `a` to `bc`
    add a, c
    ld c, a
    adc a, b
    sub a, c
    ld b, a
    ld a, c
    cp a, low(sizeof_Entity * MAX_ENTITIES)
    ret z ; Return if we've reached the end of the array
.skip
    ld hl, wEntityArray
    add hl, bc ; Apply the entity offset

    ; Check for entity
    ld a, [hli]
    ld l, [hl]
    ld h, a
    or a, l ; If this results in z, hl == 0
    jr z, .loop

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
    call RenderNPCs
    ; loop through entity array
    ; bc: offset of current entity !!! MUST NOT CHANGE C !!!
    ; loop through entity array
    ; bc: offset of current entity
    ld bc, $0000
    jr .skip
.loop
    ld a, sizeof_Entity
    ; Add `a` to `bc`
    add a, c
    ld c, a
    adc a, b
    sub a, c
    ld b, a
    ld a, c
    cp a, low(sizeof_Entity * MAX_ENTITIES)
    ret z ; Return if we've reached the end of the array
.skip
    ld hl, wEntityArray
    add hl, bc ; Apply the entity offset

    ; Check for entity
    ld a, [hli]
    ld l, [hl]
    ld h, a
    or a, l ; If this results in z, hl == 0
    jr z, .loop

    ld a, EntityDefinition_Render - EntityDefinition_Logic
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

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
    ld hl, null 
    ret

; Expanded version of MoveAndSlide which performs corner checks and only
; collides with tiles greater than or equal to TILEDATA_COLLISION.
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
    cp a, TILEDATA_COLLISION - 1
    pop bc
    pop hl
    pop de
    ; If a >= TILEDATA_COLLISION, skip movement
    jr nc, .yMovement
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
    cp a, TILEDATA_COLLISION
    ; If a < TILEDATA_COLLISION, don't slide out.
    jr c, .xBottomCornerCheck 
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
    cp a, TILEDATA_COLLISION
    ; If a < TILEDATA_COLLISION, don't slide out.
    jr c, .yMovement
    inc l
    inc [hl] ; Slide out
    dec l
    
; WARNING!!! This is a disgusting copy/paste rather than a loop.
.yMovement
    inc l ; Seek to YVel
    ld a, [hld] ; Seek to XPos
    ld b, a ; B contains Y Velocity
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
    cp a, TILEDATA_COLLISION - 1
    pop bc
    pop hl
    pop de
    ; If a >= TILEDATA_COLLISION, skip movement
    ret nc
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
    cp a, TILEDATA_COLLISION
    ; If a < TILEDATA_COLLISION, don't slide out.
    ret c
    inc l
    inc [hl] ; Slide out
    dec l
    ret

; Move the Entity based on its Velocity. Slide along collision. Detects any
; collision greater than or equal to TILEDATA_ENTITY_COLLISION
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
    cp a, TILEDATA_ENTITY_COLLISION - 1
    pop bc
    pop hl
    pop de
    ; If a >= TILEDATA_COLLISION, skip movement
    jr nc, .yMovement
    ; Handle movement
    ld a, d
    ld [hl], a ; Update X Pos. 
.yMovement
    inc l ; Seek to YVel
    ld a, [hld] ; Seek to XPos
    ld b, a ; B contains Y Velocity
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
    cp a, TILEDATA_ENTITY_COLLISION - 1
    pop bc
    pop hl
    pop de
    ; If a >= TILEDATA_COLLISION, skip movement
    ret nc
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
    ; Offset map data by X. Lower byte is safe to use.
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; Y translation (255 -> 16 * 16 or 256 ! )
    ld a, b
    and a, %11110000 ; We do need to mask out a bit...s
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
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
    ; abs(a)
    bit 7, a
    jr z, :+
    cpl
    inc a
  :
    cp a, ENTITY_DETECTION_SIZE
    jr nc, .retFail
    ld a, [hld] ; Load X
    sub a, e
    ; abs(a)
    bit 7, a
    jr z, :+
    cpl
    inc a
  :
    cp a, ENTITY_DETECTION_SIZE
    jr nc, .retFail
    dec l
    dec l ; Return to origin
    ret
.retFail
    ld hl, $0000
    ret

; Returns The index of the first entity to collide with a location in bc. 
; If a returns 0, no entity was found.
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
    xor a, a ; ld a, 0
    ret 
.continue
    ld b, h
    ld c, l
.skip
    ld hl, wEntityArray
    add hl, bc ; Apply the entity offset

    ld a, [hli] ; Load the first byte of the entity

    ; Check for entity
    ld a, [hl] ; Load the first byte of the entity
    and a, a ; If the first byte is not 0, skip the next check
    jr nz, .check
    inc l
    ld a, [hld]
    and a, a
    jr z, .loop ; if the value is *still* 0, loop.
.check

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
    ld a, 1
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

SECTION "Entity Array", WRAM0, ALIGN[8] ; Align with $00 so that we can use unsafe struct seeking
wEntityArray::
    ; define an array of `MAX_ENTITIES` Entities, each named wEntityXX
    dstructs MAX_ENTITIES, Entity, wEntity

SECTION UNION "Volatile", HRAM
hRenderByte: ; currently stores the entity's invtimer to find out if it should blink
    ds 1