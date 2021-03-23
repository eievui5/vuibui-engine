
INCLUDE "include/directions.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/enum.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/players.inc"
INCLUDE "include/switch.inc"
INCLUDE "include/tiles.inc"

/*  players.asm
    Common functions shared by the players.

Functions:

    HandlePlayers
        - Run once per frame, handling player logic and special states such as 
        the active room. Called from HandleEntities.

    PlayerInputMovement
        - Set the player's velocity based off the DPad input.
        @ input:
        - bc: Player offset ( PLAYER enum * sizeof_Entity )

    PlayerDamage
        - The common Damage state handling for all players. Includes death and 
        knockback.

    PlayerAIFollow
        - Generic "Follow the active player state."
        @ input:
        - bc: Player offset ( PLAYER enum * sizeof_Entity )

    UseItemCheck
        - Used to set the players state if they have attempted to use an item.
        @ input:
        - b:  Value of w<Player>Equipped
        - hl: Pointer to w<Player>State

Variables:

    wActivePlayer
        - The Character currently being controlled by the player. Used as an 
        offset.

    wTransitionBuffer
        - Used to make sure we only transition upon entering a transition tile.

    wAllyLogicMode
        - Used to adjust entity logic based on the layout of the current room.

    wPlayerWaiting
        - Player waiting boolean

    wPlayerRoom
        - Player world map Position. Used to keep track of which room an
        inactive player is waiting in.
    
    wPlayerEquipped
        - The currently equipped items. Lower Nibble = A, Upper Nibble = B

    wPlayerArray
        - An array of the player's entity data. Important for reusing entity
        functions

    wOctaviaProjectile
        - A reserved entity for Octavia's current spell

    wPoppyProjectiles
        - Two reserved entities for Poppy's arrows.
*/

SECTION "Player Functions", ROMX

; Run once per frame, handling player logic and special states such as the
; active room. Called from HandleEntities
HandlePlayers::

.checkOctavia

    ldh a, [hNewKeys]
    bit PADB_SELECT, a
    call nz, CyclePlayers

    ld a, PLAYER_OCTAVIA
    call PlayerRoomCheck ; If rooms do not match or player is disabled, skip.
    call z, OctaviaPlayerLogic 

.checkPoppy
    ld a, PLAYER_POPPY
    call PlayerRoomCheck ; If rooms do not match or player is disabled, skip.
    call z, PoppyPlayerLogic

.checkTiber
    ld a, PLAYER_TIBER
    call PlayerRoomCheck; If rooms do not match or player is disabled, skip.
    ; Update the current room (This needs to move to the room transition function. (Does that function even exist?))
    jp z, TiberPlayerLogic
    ret

; Players can be rendered seperately from normal entities.
RenderPlayers::
.octavia
    ld a, PLAYER_OCTAVIA
    call PlayerRoomCheck
    ld hl, wOctavia
    call z, RenderMetasprite
    
.poppy
    ld a, PLAYER_POPPY
    call PlayerRoomCheck
    ld hl, wPoppy
    call z, RenderMetasprite
    
.tiber
    ld a, PLAYER_TIBER
    call PlayerRoomCheck
    ld hl, wTiber
    jp z, RenderMetasprite
    ret

CyclePlayers:
.loop
    ld hl, wActivePlayer
    inc [hl]
    ld a, [hl]
    cp a, PLAYER_TIBER + 1
    jr nz, .zSkip
    xor a, a
    ld [hl], a
.zSkip
    ld hl, wPlayerDisabled
    add_r16_a h, l
    ld a, [hl]
    and a, a
    jr nz, CyclePlayers

    ld c, 3
    ld a, [wActivePlayer]
    ld hl, wPlayerWaitLink
    add_r16_a h, l
    ld b, [hl]
    ld hl, wPlayerWaitLink
.waitLoop
    ld a, b
    cp a, [hl] ; If the old player had a follower, update them to the new player
    jr nz, .skipSet
    ld a, [wActivePlayer]
    ld [hl], a
.skipSet
    inc hl
    dec c
    jr nz, .waitLoop
    ret

; returns `z = !(wPlayerDisabled || (wWorldMapPosition == wPlayerRoom))`
; (z is set if logic and renderer should run)
; @ a: Player Index
PlayerRoomCheck:
    ; Is player enabled?
    ld hl, wPlayerDisabled
    add_r16_a h, l
    ld a, [hl]
    and a, a
    ret nz
    add a, a
    ld hl, wPlayerRoom
    add_r16_a h, l
    ld a, [wWorldMapPositionY]
    cp a, [hl]
    ret nz ; If the rooms match, call normally.
    inc hl
    ld a, [wWorldMapPositionX]
    cp a, [hl]
    ret ; If the rooms match, call normally.

; Sets the player's velocity based off the DPad.
; @ bc: PLAYER enum * sizeof_Entity
PlayerInputMovement::
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

; The common Damage state handling for all players. Includes death and knockback.
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

; Generic "Follow the active player state." Does not move the Ally, only sets
; velocity and direction.
; @ bc: Player offset ( PLAYER enum * sizeof_Entity )
; @ e:  Ally distance
PlayerAIFollow::
    push de
    ld a, [wActivePlayer]
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ld de, wPlayerArray + Entity_YPos
    add_r16_a d, e
    find_player Entity_YPos
    ; de: target
    ; hl: self
    ; Distance = target - self.
    ld a, [hli] ; Self Y
    ld b, a
    ld a, [de] ; Target Y
    inc e
    sub a, b ; Distance Y
    ld b, a

    ld a, [de] ; Target X
    ld e, a
    ld d, b ; Store distance Y in d
    ld a, [hl] ; Self X
    ld b, a
    ld a, e
    sub a, b ; Distance X
    ld e, a
    ; de: distance vector
    ; hl: self X

    ; First, let's set direction.
    ; Seek to our direction field
    ld a, Entity_Direction - Entity_XPos
    add a, l
    ld l, a

    ld a, d
    abs_a
    ld b, a
    ld a, e
    abs_a
    ; ld c, a (I immediatly need c in a, so this is needless.)
    ; ba = abs(de)

    cp a, b 
    jr nc, .xDirGreater
.yDirGreater
    bit 7, d ; If d is negative
    jr z, .posYDir
    ld a, DIR_UP
    jr .storeYDir
.posYDir
    ASSERT DIR_DOWN == 0
    xor a, a
.storeYDir
    ld [hl], a
    jr .velocity
.xDirGreater
    bit 7, e ; If d is negative
    jr z, .posXDir
    ld a, DIR_LEFT
    jr .storeXDir
.posXDir
    ld a, DIR_RIGHT
.storeXDir
    ld [hl], a

.velocity
    ld a, Entity_YVel - Entity_Direction
    add a, l
    ld l, a
    pop bc

.yVel
    ld a, d
    abs_a
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
    abs_a
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
    abs_a
    ld b, a
    ld a, [hl]
    abs_a
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
    ld a, [hl]
    add a, FRAMEOFF_STEP
    ld [hl], a
    ret

; Has the player used an item? Which one?
; @ b:  Value of wPlayerEquipped
; @ hl: Pointer to wPlayerState (preserved)
UseItemCheck::
.aCheck
    ldh a, [hNewKeys]
    bit PADB_A, a
    jr z, .bCheck
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

; @ `hl`: Pointer to Player
InteractionCheck::
    ldh a, [hNewKeys]
    bit PADB_A, a
    ret z
    call GetEntityTargetPosition
    call CheckAllyCollision
    cp a, $FF
    ret z
    add a, a ; a * 2
    ld de, PlayerDialogueLookup
    add_r16_a d, e
    ld a, [de]
    ld b, a
    inc de
    ld a, [de]
    ld d, a
    ld e, b
    ; `de` is now the dialogue lookup table!
    ; Load current dialogue mode and add to table
    ; Load pointer into de
    ld a, [de]
    ld b, a
    inc de
    ld a, [de]
    ld d, a
    ld e, b
    ld b, b

    ld a, ENGINE_STATE_SCRIPT
    ldh [hEngineState], a
    ld hl, wActiveScriptPointer
    ld a, bank(OctaviaGeneric)
    ld [hli], a
    ld a, e
    ld [hli], a
    ld a, d
    ld [hli], a
    ret

; Returns the entity position offset by their facing direction in `de` (X, Y)
; @ `hl`: pointer to entity
GetEntityTargetPosition::
    ld a, Entity_Direction - Entity_DataPointer
    add a, l
    ld l, a
    ld d, [hl]
    ld a, Entity_YPos - Entity_Direction
    add a, l
    ld l, a
    ld a, d
    ASSERT DIR_DOWN == 0
    and a, a
    jr z, .down
    ASSERT DIR_UP == 1
    dec a
    jr z, .up
    inc l
    ASSERT DIR_RIGHT == 2
    dec a
    jr z, .right
    ASSERT DIR_LEFT == 3
.left
    ld a, -16
    jr .storeX
.right 
    ld a, 16
.storeX
    add a, [hl]
    ld e, a
    dec l
    ld d, [hl]
    ret
.down
    ld a, 16
    jr .storeY
.up 
    ld a, -16
.storeY
    add a, [hl]
    ld d, a
    inc l
    ld e, [hl]
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
ScreenTransitionCheck::
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
    ; End the frame early.
    ld sp, wStackOrigin
    jp Main.end
.clearTransBuffer
    xor a, a
    ld [wTransitionBuffer], a
    ret

PlayerSetWaitLink:
.octavia::
    ld a, PLAYER_OCTAVIA
    jr .store
.poppy::
    ld a, PLAYER_POPPY
    jr .store
.tiber::
    ld a, PLAYER_TIBER
    jr .store
.store
    ld hl, wPlayerWaitLink
    add_r16_a h, l
    ld a, [wActivePlayer]
    ld [hl], a
    ret

PlayerCameraInterpolation::
    ; Offset to the active player.
    ld a, [wActivePlayer]
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ld hl, wPlayerArray + Entity_YPos
    add_r16_a h, l

    ; Y Interp
    ld a, [wSCYBuffer]
    ld b, a
    ld a, [hli] ; Seek to X!
    sub a, 80 + 8
    sub a, b
    sra a ; divide by 8, conserve the sign
    sra a 
    sra a 
    add a, b
    ld e, a

    ; X Interp
    ld a, [wSCXBuffer]
    ld b, a
    ld a, [hl]
    sub a, 72 + 8
    sub a, b
    sra a ; divide by 8, conserve the sign
    sra a 
    sra a 
    add a, b
    ld d, a

    jp SetScrollBuffer

; Checks if any of the active players are colliding with `de`. Returns a pointer
; to the detected player in `hl`, $0000 if no player was found.
; @ de: Check Position (Y, X)
CheckPlayerCollision::
    ld hl, wOctavia
    call CheckEntityCollision
    xor a, a
    cp a, h
    ret nz ; If 0 was not returned, we found a player. Return.
    cp a, l
    ret nz
    ; Otherwise, keep checking
    ld hl, wPoppy
    call CheckEntityCollision
    xor a, a
    cp a, h
    ret nz ; If 0 was not returned, we found a player. Return.
    cp a, l
    ret nz
    ; Otherwise, keep checking
    ld hl, wTiber
    jp CheckEntityCollision ; We don't need any special checks at the end.

; Checks if any of the ally players are colliding with `de`. Returns a pointer
; to the detected ally in `hl`. Also returns the ally's index in a (0-2).
; Returns `$FF` in `a` if nothing was found.
; @ de: Check Position (Y, X)
CheckAllyCollision::
;octaviaCheck
    ld a, [wActivePlayer]
    ASSERT PLAYER_OCTAVIA == 0
    and a, a
    jr z, .poppySkip
    ld hl, wOctavia
    call CheckEntityCollision
    xor a, a
    cp a, h
    jr nz, .retOctavia ; If 0 was not returned, we found a player. Return.
    cp a, l
    jr nz, .retOctavia
.poppyCheck
    ld a, [wActivePlayer]
    ASSERT PLAYER_POPPY == 1
    dec a
    jr z, .tiberSkip
    ; if we already know octavia is the active player, we don't need to check poppy
.poppySkip 
    ld hl, wPoppy
    call CheckEntityCollision
    xor a, a
    cp a, h
    jr nz, .retPoppy ; If 0 was not returned, we found a player. Return.
    cp a, l
    jr nz, .retPoppy
    ; Otherwise, keep checking
.tiberCheck
    ld a, [wActivePlayer]
    cp a, PLAYER_TIBER
    jr z, .retNone
.tiberSkip
    ld hl, wTiber
    call CheckEntityCollision ; We don't need any special checks at the end.
    xor a, a
    cp a, h
    jr nz, .retTiber ; If 0 was not returned, we found a player. Return.
    cp a, l
    jr nz, .retTiber
.retNone
    ld a, $FF
    ret
.retOctavia
    ASSERT PLAYER_OCTAVIA == 0
    xor a, a
    ret
.retPoppy
    ld a, PLAYER_POPPY
    ret
.retTiber
    ld a, PLAYER_TIBER
    ret

; Used to convert the 4-bit item enum into the player states
ItemStateLoopup::
    ; The first item for each character should correspond to the same state!
    ; Eg, Sword state = 2, Wand state = 2
    ASSERT ITEM_FIRE_WAND == 1
    db PLAYER_STATE_FIRE_WAND

; Used to lookup the dialogue corresponding to the current room.
ASSERT bank(OctaviaGeneric) == bank(PoppyGeneric) && bank(PoppyGeneric) == bank(TiberGeneric)
PlayerDialogueLookup:
    dw .octavia, .poppy, .tiber ; faster I guess?
.octavia
    dw OctaviaGeneric
.poppy
    dw PoppyGeneric
.tiber
    dw TiberGeneric

SECTION "Player Variables", WRAM0

; The Character currently being controlled by the player. Used as an offset.
wActivePlayer::
    ds 1

; Make sure we only transition upon *entering* a transition tile.
wTransitionBuffer::
    ds 1

; Used to adjust entity logic based on the layout of the current room
wAllyLogicMode::
    ds 1

; Player disablers
wPlayerDisabled::
.octavia::
    ds 1
.poppy::
    ds 1
.tiber::
    ds 1

; Player waiting and linking. If the value does not match that of the active 
; player they should wait. This is important because it means switching players
; will follow each other independantly; switching from an active player to a
; waiting player will cause the other group to wait.
wPlayerWaitLink::
.octavia::
    ds 1
.poppy::
    ds 1
.tiber::
    ds 1 

; Player world map Position. Used to keep track of which room an inactive
; player is waiting in.
wPlayerRoom::
.octavia::
    ds 2
.poppy::
    ds 2
.tiber::
    ds 2

; The currently equipped items.
; Lower Nibble = A, Upper Nibble = B
wPlayerEquipped::
.octavia::
    ds 1
.poppy::
    ds 1
.tiber::
    ds 1

SECTION "Player Array", WRAM0, ALIGN[$08]
wPlayerArray::
    dstruct Entity, wOctavia
    dstruct Entity, wPoppy
    dstruct Entity, wTiber

    dstruct Entity, wOctaviaProjectile
    dstructs 2, Entity, wPoppyProjectiles