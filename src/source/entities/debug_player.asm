
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
    ld b, a
    ld c, [hl]
    ld hl, OctaviaDown
    call RenderMetasprite

    ret

BOUNDING_BOX_X EQU 6 ; A bit smaller than 8*8, because that feel/looks better.
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
    call LookupMapData
    ld a, [hl]
    and a, a ; cp a, $00
    pop hl
    pop de
    jr nz, .yMovement ; Is there data here? Don't move.
    ld a, d
    ld [hl], a ; Update X Pos. 
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
    call LookupMapData
    ld a, [hl]
    and a, a ; cp a, $00
    pop hl
    pop de
    ret nz ; Is there data here? Don't move.
    ld [hl], d ; Update Y Pos.
    ret




    
    ; deprecated code 
    ld a, [hli] ; Load the Y velocity, seek to Entity_XVel
    ld b, a ; this is faster than ld b, [hl] inc hl (4c, 2b vs 3c, 2b)
    ld a, [hl] ; Load the X velocity
    ld c, a
    StructSeekUnsafe l, Entity_XVel, Entity_XPos
    ld a, c ; It's better to do X first so that we end on Y
    add a, [hl]
    ld c, a ; C has become the X destination
    dec l ; Seek to the X Positon

    ld a, b 
    add a, [hl] ; Add the Y pos into Y Vel
    ld b, a ; B has become the Y destination

    push bc ; we need to save the target location
    push hl ; and the struct pointer. It's at XPos
    call LookupMapData ; Find the tile we're about to step on
    ld a, [hl] ; Load the tile we're about to step on
    pop hl
    pop bc

    and a, a ; Is the data clear?
    ret nz
    ld a, b ; Move if a == 0
    ld [hli], a
    ld a, c
    ld [hld], a ; We need to restore this to Y because the ret has no idea which path was taken
    ret

; Locates a given position in the map data and returns it in HL. Destroys all registers.
; @ b:  Y position
; @ c:  X position
LookupMapData:
    ld de, wMapData
    ; X translation (255 -> 31)
    srl c ; c / 2
    srl c ; c / 4
    srl c ; c / 8 !!!
    dec c ; There's a bit of a rounding error here, so we need to decrement.
    ld a, e
    add a, c
    ld e, a ; Offset map data by X. Lower byte is safe to use.
    ; Y translation (255 -> 1023)
    ld a, %11111000 ; Bitmask, we want to ignore the lower 3
    and a, b ; This skips division and much of the multiplication.
    sub a, %00010000 ; Again, fix a rounding error
    ld h, $00
    ld l, a ; We need to swap into hl since $0400 won't fit in 8 bits.
    add hl, hl ; b * 16
    add hl, hl ; b * 32 !!!
    add hl, de ; HL now contains the mapdata, offset by the X and Y positions
    ret