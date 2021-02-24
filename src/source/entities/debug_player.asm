
; An Entity that can be controlled by inputs to test collision

DebugPlayer::
    FindEntity ; Locate my struct data
    StructSeekUnsafe l, Entity_YPos, Entity_YVel
    ldh a, [hCurrentKeys]

.downCheck
    ld [hl], 0 ; reset Y velocity
    bit PADB_DOWN, a ; Is down pressed?
    jr z, .upCheck
    ld [hl], 1 ; Y velocity of 1
    jr .rightCheck ; Skip .upCheck
.upCheck
    bit PADB_UP, a ; Is up pressed?
    jr z, .rightCheck
    ld [hl], -1 ; Y velocity of -1

.rightCheck
    inc hl ; Move to the X Data
    ld [hl], 0 ; reset X velocity
    bit PADB_RIGHT, a ; Is right pressed?
    jr z, .leftCheck
    ld [hl], 1 ; X velocity of 1
    jr .moveAndSlide
.leftCheck
    bit PADB_LEFT, a ; Is left pressed
    jr z, .moveAndSlide
    ld [hl], -1 ; X velocity of -1

.moveAndSlide
    call MoveAndSlide
    
.render 

    ld a, [hli]
    sub a, 80 + 8
    ldh [rSCY], a
    ld a, [hld]
    sub a, 72 + 8
    ldh [rSCX], a

    ld a, [hli]
    ld b, a
    ld c, [hl]
    ld hl, OctaviaDown
    call RenderMetasprite

    ret

BOUNDING_BOX_X EQU 6 ; A bit smaller than 16*16, because that feel/looks better.
BOUNDING_BOX_Y EQU 6

; Move the Entity based on its Velocity. Slide along collision.
; @ hl: pointer to Entity_XVel. 
MoveAndSlide:
.xMovement
    ld c, [hl] ; C contains X Velocity
    StructSeekUnsafe l, Entity_XVel, Entity_YPos
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
    cp a, TILE_COLLISION
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
    cp a, TILE_COLLISION; Is there a wall on the corner?
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
    cp a, TILE_COLLISION; Is there a wall on the corner?
    jr nz, .yMovement
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
    cp a, TILE_COLLISION
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
    cp a, TILE_COLLISION; Is there a wall on the corner?
    ret nz
    inc l
    inc [hl] ; Slide out
    dec l
    ret


; Locates a given position in the map data and returns it in HL. Destroys all registers.
; @ b:  Y position
; @ c:  X position
LookupMapData:

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