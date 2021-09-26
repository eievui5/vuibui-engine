INCLUDE "include/directions.inc"
INCLUDE "include/entity.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/players.inc"

SECTION "Player Input Movement", ROM0

; Sets the player's velocity based off the DPad.
; @ bc: PLAYER enum * sizeof_Entity
PlayerInputMovement::
    ld hl, wPlayerArray + Entity_YVel
    add hl, bc
    ; Reset velocity if we have control over movement
    xor a, a
    ld [hli], a ; YVel
    ld [hl], a ; XVel

    ; Are we even pressing the DPad right now?
    ldh a, [hCurrentKeys]
    and a, $F0
    jr z, .activeMoveAndSlide ; Let's skip this part if not.
    ld hl, wPlayerArray + Entity_Timer
    add hl, bc
    ; Every 32th tick (~ 1/2 second)...
    ld a, [hl]
    inc a 
    ld [hld], a 
    bit 4, a 
    jr z, .activeMoveDown
    dec l
    dec l ; Frame!
    ; ...Offset to step animation
    ld a, FRAMEOFF_STEP
    ld [hl], a
.activeMoveDown
    ld hl, wPlayerArray + Entity_YVel
    add hl, bc
    ldh a, [hCurrentKeys]
    bit PADB_DOWN, a
    jr z, .activeMoveUp
    ld a, 1
    ld [hl], a
    ; Update facing
    ld hl, wPlayerArray + Entity_Direction
    add hl, bc
    ASSERT DIR_DOWN == 0
    xor a, a
    ld [hl], a
    ; Restore a
    ldh a, [hCurrentKeys] 
    ; Down and Up cannot be pressed, so skip to Left
    jr .activeMoveLeft
.activeMoveUp
    ld hl, wPlayerArray + Entity_YVel
    add hl, bc
    bit PADB_UP, a
    jr z, .activeMoveLeft
    ld a, -1
    ld [hl], a
    ; Update facing
    ld hl, wPlayerArray + Entity_Direction
    add hl, bc
    ld a, DIR_UP
    ld [hl], a
    ; Restore a
    ldh a, [hCurrentKeys] 
.activeMoveLeft
    ld hl, wPlayerArray + Entity_XVel
    add hl, bc
    bit PADB_LEFT, a
    jr z, .activeMoveRight
    ld a, -1
    ld [hl], a
    ; Update facing
    ld hl, wPlayerArray + Entity_Direction
    add hl, bc
    ld a, DIR_LEFT
    ld [hl], a
    ; Don't bother restoring a
    ; Left and Right cannot be pressed, so skip to Render
    jr .activeMoveAndSlide
.activeMoveRight
    ld hl, wPlayerArray + Entity_XVel
    add hl, bc
    bit PADB_RIGHT, a
    jr z, .activeMoveAndSlide
    ld a, 1
    ld [hl], a
    ld hl, wPlayerArray + Entity_Direction
    add hl, bc
    ld a, DIR_RIGHT
    ld [hl], a
    ; Don't bother restoring a
.activeMoveAndSlide
    ld hl, wPlayerArray
    add hl, bc
    jp PlayerMoveAndSlide

SECTION "Player AI Follow", ROM0

; Generic "Follow the active player state." Does not move the Ally, only sets
; velocity and direction.
; @ bc: Player offset ( PLAYER enum * sizeof_Entity )
; @ e:  Ally distance
PlayerAIFollow::
    push de
    ld a, [wActivePlayer]
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ; Add `a` to `wPlayerArray + Entity_YPos` and store in `de`
    add a, LOW(wPlayerArray + Entity_YPos)
    ld e, a
    adc a, HIGH(wPlayerArray + Entity_YPos)
    sub a, e
    ld d, a

    ld hl, wPlayerArray + Entity_YPos
    add hl, bc

    call GetEntityDistance
    ; de: distance vector
    ; hl: self X

    ; First, let's set direction.
    ; Seek to our direction field
    ld a, Entity_Direction - Entity_XPos
    add a, l
    ld l, a

    call GetDistanceDirection
    ld [hl], a

.velocity
    ld a, Entity_YVel - Entity_Direction
    add a, l
    ld l, a
    pop bc ; Pop the input `e` into `c`

.yVel
    ld a, d
    ; abs(a)
    bit 7, a
    jr z, :+
    cpl
    inc a
  :
    cp a, c
    jr c, .yVelZero
    bit 7, d
    jr z, .yVelPos
.yVelNeg
    ld a, -1
    jr .storeYVel
.yVelPos
    ld a, 1
    jr .storeYVel
.yVelZero
    xor a, a
.storeYVel
    ld [hli], a
.xVel
    ld a, e
    ; abs(a)
    bit 7, a
    jr z, :+
    cpl
    inc a
  :
    cp a, c
    jr c, .xVelZero
    bit 7, e
    jr z, .xVelPos
.xVelNeg
    ld a, -1
    jr .storeXVel
.xVelPos
    ld a, 1
    jr .storeXVel
.xVelZero
    xor a, a
.storeXVel
    ld [hld], a
    ; abs(a)
    bit 7, a
    jr z, :+
    cpl
    inc a
  :
    ld b, a
    ld a, [hl]
    ; abs(a)
    bit 7, a
    jr z, :+
    cpl
    inc a
  :
    add a, b
    ret z

    ; Animation
    ld a, Entity_Timer - Entity_YVel
    add a, l
    ld l, a
    inc [hl]
    ld a, [hl]
    bit 4, a
    ret z
    dec l
    dec l
    dec l
    ld a, FRAMEOFF_STEP
    ld [hl], a
    ret