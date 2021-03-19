
INCLUDE "include/directions.inc"
INCLUDE "include/enum.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/players.inc"
INCLUDE "include/switch.inc"
INCLUDE "include/tiles.inc"

SECTION "Player Functions", ROMX

; Sets the player's velocity based off the DPad.
; @ bc: PLAYER enum * sizeof_Entity
PlayerInputMovement:
    find_player Entity_YVel
    ; Reset velocity if we have control over movement
    xor a, a
    ld [hli], a ; YVel
    ld [hl], a ; XVel

    ; Are we even pressing the DPad right now?
    ldh a, [hCurrentKeys]
    and a, $F0
    jr z, .activeMoveAndSlide ; Let's skip this part if not.
    find_player Entity_Timer
    ; Every 32th tick (~ 1/2 second)...
    ld a, [hl]
    inc a 
    ld [hld], a 
    bit 4, a 
    jr z, .activeMoveDown
    dec l
    dec l ; Frame!
    ; ...Offset to step animation
    ld a, [hl]
    add a, FRAMEOFF_STEP
    ld [hl], a
.activeMoveDown
    find_player Entity_YVel
    ldh a, [hCurrentKeys]
    bit PADB_DOWN, a
    jr z, .activeMoveUp
    ld a, 1
    ld [hl], a
    ; Update facing
    find_player Entity_Direction
    ASSERT DIR_DOWN == 0
    xor a, a
    ld [hl], a
    ; Restore a
    ldh a, [hCurrentKeys] 
    ; Down and Up cannot be pressed, so skip to Left
    jr .activeMoveLeft
.activeMoveUp
    find_player Entity_YVel
    bit PADB_UP, a
    jr z, .activeMoveLeft
    ld a, -1
    ld [hl], a
    ; Update facing
    find_player Entity_Direction
    ld a, DIR_UP
    ld [hl], a
    ; Restore a
    ldh a, [hCurrentKeys] 
.activeMoveLeft
    find_player Entity_XVel
    bit PADB_LEFT, a
    jr z, .activeMoveRight
    ld a, -1
    ld [hl], a
    ; Update facing
    find_player Entity_Direction
    ld a, DIR_LEFT
    ld [hl], a
    ; Don't bother restoring a
    ; Left and Right cannot be pressed, so skip to Render
    jr .activeMoveAndSlide
.activeMoveRight
    find_player Entity_XVel
    bit PADB_RIGHT, a
    jr z, .activeMoveAndSlide
    ld a, 1
    ld [hl], a
    find_player Entity_Direction
    ld a, DIR_RIGHT
    ld [hl], a
    ; Don't bother restoring a
.activeMoveAndSlide
    find_player
    jp PlayerMoveAndSlide

PlayerDamage::
    find_player Entity_CollisionData
    ld a, [hl]
    and a, $0F
    jr z, .timer ; No damage left? skip...
    ld d, a
    xor a, a
    ld [hli], a ; Sekk to health
    ld a, [hl]
    sub a, d
    jr nc, .storeHealth ; If damage < health, we're not dead!
    xor a, a
    ; Death Stuff Here.
.storeHealth
    ld [hl], a
.timer
    find_player Entity_Timer
    ld a, [hl]
    dec a
    ld [hld], a ; Seek to state
    jr nz, .knockback
    ASSERT PLAYER_STATE_NORMAL == 0
    ; if we're down here, a already = 0
    ld [hl], a
.knockback
    find_player
    jp PlayerMoveAndSlide

; Has the player used an item? Which one?
; @ b:  Value of wPlayerEquipped
; @ hl: Pointer to wPlayerState (preserved)
UseItemCheck::
.aCheck
    ldh a, [hNewKeys]
    bit PADB_A, a
    jr z, .bCheck
    ; First check for generic interaction
    ; Now for items!
    ld a, b
    and a, $0F ; Check if A item exists... (and mask out B)
    jr nz, .loadItemState
    ret ; Nothing there? get out of here!
.bCheck
    ldh a, [hNewKeys]
    bit PADB_B, a
    ret z
    ld a, b
    swap a ; Swap around to B item
    and a, $0F ; Check if B item exists... (and mask out A)
    ret z ; Nothing there? get out of here!
.loadItemState ; Queue up the item state to run next frame
    ld de, ItemStateLoopup - 1
    add_r16_a d, e
    dec l
    xor a, a
    ld [hli], a ; Reset flags so that item states can initiallize.
    ld a, [de] ; Load state based off item ID
    ld [hl], a
    ret

; Move the player during screen transition.
PlayerTransitionMovement::
    ld a, [wActivePlayer]
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ld hl, wPlayerArray + Entity_YPos
    add_r16_a h, l
    ld a, [wRoomTransitionDirection]
    ASSERT TRANSDIR_DOWN == 1
    dec a
    jr z, .down
    ASSERT TRANSDIR_UP == 2
    dec a
    jr z, .up
    inc l ; Swap to X
    ASSERT TRANSDIR_RIGHT == 3
    dec a
    jr z, .right
    ASSERT TRANSDIR_LEFT == 4
    jr .left
.down
    ld a, [hl]
    ; These location checks are slightly off, since sprites are not centered.
    cp a, 24 ; 24 - stops on the first tile
    ret z ; Are we already there?
    inc [hl] ; No? Then move down
    bit 4, a ; Let's just use YPos as the animation timer.
    jr nz, .downStepFrame
    ld b, PLAYER_FRAME_DOWN
    jr .verticleStoreFrame
.downStepFrame
    ld b, PLAYER_FRAME_DOWN_STEP
    jr .verticleStoreFrame
.up
    ld a, [hl]
    cp a, 8 ; Stop on the first tile
    ret z ; Are we already there?
    dec [hl] ; No? Then move up
    bit 4, a ; Let's just use YPos as the animation timer.
    jr nz, .upStepFrame
    ld b, PLAYER_FRAME_UP
    jr .verticleStoreFrame
.upStepFrame
    ld b, PLAYER_FRAME_UP_STEP
.verticleStoreFrame
    ld a, Entity_Frame - Entity_YPos
    add a, l
    ld l, a
    ld [hl], b
    ret
.right
    ld a, [hl]
    cp a, 16 ; Stop on the first tile
    ret z ; Are we already there?
    inc [hl] ; No? Then move right
    bit 4, a ; Let's just use XPos as the animation timer.
    jr nz, .rightStepFrame
    ld b, PLAYER_FRAME_RIGHT
    jr .horizontalStoreFrame
.rightStepFrame
    ld b, PLAYER_FRAME_RIGHT_STEP
    jr .horizontalStoreFrame
.left
    ld a, [hl]
    cp a, 1 ; Stop on the first tile
    ret z ; Are we already there?
    dec [hl] ; No? Then move left
    bit 4, a ; Let's just use XPos as the animation timer.
    jr nz, .leftStepFrame
    ld b, PLAYER_FRAME_LEFT
    jr .horizontalStoreFrame
.leftStepFrame
    ld b, PLAYER_FRAME_LEFT_STEP
.horizontalStoreFrame
    ld a, Entity_Frame - Entity_XPos
    add a, l
    ld l, a
    ld [hl], b
    ret

; Looks up a position to see if it contains a transition tile, and transitions
; to the next screen if it does.
; @ b:  Y position
; @ c:  X position
ScreenTransitionCheck:
    call LookupMapData
    ld a, [hl]
    ; Check if we are within the transtion tiles.
    ASSERT TILE_TRANSITION_LEFT - TILE_TRANSITION_DOWN == 3
    ; We don't *actually* want this to be one lower, but the transition routine 
    ; expects DIR + 1
    sub a, TILE_TRANSITION_DOWN - 1 
    ; And we *do* want this 1 higher, but we need to offset the - we just did.
    cp a, TILE_TRANSITION_LEFT - TILE_TRANSITION_DOWN + 2
    jr nc, .clearTransBuffer ; Clear wTransitionBuffer if we're not transitioning now.
    ld h, a
    ld a, [wTransitionBuffer]
    and a, a
    ret nz ; If the transition buffer is set, do not transition again
    inc a
    ; Otherwise, set the buffer so that we don't rapidly switch rooms
    ld [wTransitionBuffer], a 
    ld a, h
    ; If we're standing on a transition tile, queue up a transition
    ld [wRoomTransitionDirection], a
    ; Now calculate the new map to load
    ld hl, wWorldMapPositionY
.downCheck
    dec a
    jr nz, .upCheck
    inc [hl]
    jr .update
.upCheck
    dec a
    jr nz, .rightCheck
    dec [hl]
    jr .update
.rightCheck
    ASSERT wWorldMapPositionY - wWorldMapPositionX == 1
    dec hl
    dec a
    jr nz, .leftCheck
    inc [hl]
    jr .update
.leftCheck
    dec [hl]
.update
    call UpdateActiveMap
    call RenderPlayers
    pop hl ; Clear call
    jp Main.end ; Skip main rendering during this frame.
.clearTransBuffer
    xor a, a
    ld [wTransitionBuffer], a
    ret

; Used to convert the 4-bit item enum into the player states
ItemStateLoopup::
    ; The first item for each character should correspond to the same state!
    ; Eg, Sword state = 2, Wand state = 2
    ASSERT ITEM_FIRE_WAND == 1
    db PLAYER_STATE_FIRE_WAND

SECTION "Player Variables", WRAM0

; The Character currently being controlled by the player. Used as an offset.
wActivePlayer::
    ds 1

; Make sure we only transition upon *entering* a transition tile.
wTransitionBuffer::
    ds 1

; The currently equipped items.
; Lower Nibble = A, Upper Nibble = B
wOctaviaEquipped:: 
    ds 1
; The currently equipped items.
; Lower Nibble = A, Upper Nibble = B
wPoppyEquipped::
    ds 1
; The currently equipped items.
; Lower Nibble = A, Upper Nibble = B
wTiberEquipped::
    ds 1

SECTION "Player Array", WRAM0, ALIGN[$08]
wPlayerArray::
    dstruct Entity, wOctavia
    dstruct Entity, wPoppy
    dstruct Entity, wTiber

    dstruct Entity, wOctaviaProjectile
    dstructs 2, Entity, wPoppyProjectiles