INCLUDE "include/banks.inc"
INCLUDE "include/bool.inc"
INCLUDE "include/directions.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/enum.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/map.inc"
INCLUDE "include/players.inc"
INCLUDE "include/switch.inc"
INCLUDE "include/tiledata.inc"

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

SECTION "Player Functions", ROM0

; Run once per frame, handling player logic and special states such as the
; active room. Called from HandleEntities
HandlePlayers::

.checkOctavia

    ldh a, [hNewKeys]
    bit PADB_SELECT, a
    call nz, CyclePlayers

    ld a, PLAYER_OCTAVIA
    call PlayerActivityCheck.disabled ; If rooms do not match or player is disabled, skip.
    jr nz, .checkPoppy
    ld a, BANK(OctaviaPlayerLogic)
    swap_bank
    call OctaviaPlayerLogic 
    ld a, [wOctaviaSpellActive]
    and a, a
    ld a, BANK(OctaviaSpellLogic)
    swap_bank
    call nz, OctaviaSpellLogic

.checkPoppy
    ld a, PLAYER_POPPY
    call PlayerActivityCheck.disabled ; If rooms do not match or player is disabled, skip.
    jr nz, .checkTiber    
    ld a, BANK(PoppyPlayerLogic)
    swap_bank
    call PoppyPlayerLogic
    ld a, [wPoppyActiveArrows]
    and a, a
    jr z, .checkTiber
    ; Just an unrolled entity handler for arrows...
    ld a, BANK(PoppyArrowLogic)
    swap_bank
.poppyArrow0
    ld hl, wPoppyArrow0
    ASSERT HIGH(PoppyArrow) != $00
    ld a, [hl]
    and a, a
    jr z, .poppyArrow1
    ld bc, sizeof_Entity * 0
    call PoppyArrowLogic
.poppyArrow1
    ld hl, wPoppyArrow1
    ASSERT HIGH(PoppyArrow) != $00
    ld a, [hl]
    and a, a
    jr z, .checkTiber
    ld bc, sizeof_Entity * 1
    call PoppyArrowLogic

.checkTiber
    ld a, PLAYER_TIBER
    call PlayerActivityCheck.disabled; If rooms do not match or player is disabled, skip.
    ret nz
    ld a, BANK(TiberPlayerLogic)
    swap_bank
    jp TiberPlayerLogic

; Players can be rendered seperately from normal entities.
RenderPlayers::
.octavia
    ld a, PLAYER_OCTAVIA
    call PlayerActivityCheck.disabled
    jr nz, .poppy
    ld hl, wOctavia
    call RenderMetaspriteDirection.foreign
    ld a, [wOctaviaSpellActive]
    and a, a
    jr z, .poppy
    ld hl, wOctaviaSpell
    call RenderMetasprite.foreign

.poppy
    ld a, PLAYER_POPPY
    call PlayerActivityCheck.disabled
    jr nz, .tiber
    ld hl, wPoppy
    call RenderMetaspriteDirection.foreign
    ; Just an unrolled entity handler for arrows...
.poppyArrow0
    ld hl, wPoppyArrow0
    ASSERT HIGH(PoppyArrow) != $00
    ld a, [hl]
    and a, a
    call nz, RenderMetasprite.foreign
.poppyArrow1
    ld hl, wPoppyArrow1
    ASSERT HIGH(PoppyArrow) != $00
    ld a, [hl]
    and a, a
    call nz, RenderMetasprite.foreign

.tiber
    ld a, PLAYER_TIBER
    call PlayerActivityCheck.disabled
    ld hl, wTiber
    jp z, RenderMetaspriteDirection.foreign
    ret

RenderPlayersTransition::
.octavia
    ld a, PLAYER_OCTAVIA
    call PlayerActivityCheck.waiting
    ld hl, wOctavia
    call z, RenderMetaspriteDirection.foreign
.poppy
    ld a, PLAYER_POPPY
    call PlayerActivityCheck.waiting
    ld hl, wPoppy
    call z, RenderMetaspriteDirection.foreign
.tiber
    ld a, PLAYER_TIBER
    call PlayerActivityCheck.waiting
    ld hl, wTiber
    jp z, RenderMetaspriteDirection.foreign
    ret

; Cycle to the next player, skipping those that are disabled. Update the players'
; waiting link.
CyclePlayers:
    ld hl, wActivePlayer
    inc [hl]
    ld a, [hl]
    cp a, PLAYER_TIBER + 1
    jr nz, .zSkip
    xor a, a
    ld [hl], a
.zSkip
    ; Is player enabled?
    call PlayerActivityCheck.disabled
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

; Various logic checks to determine the activity of players. Z is set if the 
; checks all pass. `a: Player Index`
; @ In order of sensitivity, the different modes are:
; @ .waiting: `z = !(wPlayerWaitlink[a] == wActivePlayer || wPlayerDisabled[a] || (wWorldMapPosition == wPlayerRoom[a]))`
; @ .disabled: `z = !(wPlayerDisabled[a] || (wWorldMapPosition == wPlayerRoom[a]))`
; @ .room: `z = !(wWorldMapPosition == wPlayerRoom[a])`
PlayerActivityCheck::
.waiting::
    ld b, a
    ld hl, wPlayerWaitLink
    add_r16_a h, l
    ld a, [wActivePlayer]
    cp a, [hl]
    ret nz
    ld a, b
.disabled::
    ; Is player enabled?
    ld b, a
    ld hl, wPlayerDisabled
    add_r16_a h, l
    ld a, [hl]
    and a, a
    ret nz
    ld a, b
.room::
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
    ld a, FRAMEOFF_STEP
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
    add_r16_a de
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
    pop bc ; Pop the input `e` into `c`

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
    ld a, FRAMEOFF_STEP
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
    add a, PLAYER_STATE_ITEM_START ; Offset items to states
    ld b, a
    xor a, a
    dec l
    ld [hli], a ; Reset flags so that item states can initiallize.
    ld [hl], b
    ret

; Check if the players are trying to talk. If this succeeds a super return is 
; performed, and player logic will end.
; @ `hl`: Pointer to Player. 
InteractionCheck::
    ldh a, [hNewKeys]
    bit PADB_A, a
    ret z
    call GetEntityTargetPosition
    call CheckAllyCollision
    cp a, $FF
    ret z
    add a, a ; a * 2 (Pointer)
    ld hl, PlayerDialogueLookup
    add_r16_a hl
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; `hl` is now the target player's dialogue lookup table

    ; Load current dialogue mode and add to table

    ld c, 3 ; bank + pointer
    ld de, wActiveScriptPointer
    rst memcopy_small

    ld a, ENGINE_STATE_SCRIPT
    ldh [hEngineState], a
    pop hl ; Super ret!
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
    add_r16_a hl
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
    dec a
    jr z, .left
    ret
.down
    ld a, [hl]
    ; These location checks are slightly off, since sprites are not centered.
    cp a, 24 ; 24 - stops on the first tile
    jr z, .updateAllyPositions ; Are we already there?
    inc [hl] ; No? Then move down    
    jr .animatePlayerY
.up
    ld a, [hl]
    cp a, 8 ; Stop on the first tile
    jr z, .updateAllyPositions ; Are we already there?
    dec [hl] ; No? Then move up
    jr .animatePlayerY
.right
    ld a, [hl]
    cp a, 16 ; Stop on the first tile
    jr z, .updateAllyPositions ; Are we already there?
    inc [hl] ; No? Then move right
    jr .animatePlayerX
.left
    ld a, [hl]
    cp a, 1 ; Stop on the first tile
    jr z, .updateAllyPositions ; Are we already there?
    dec [hl] ; No? Then move left
.animatePlayerX
    dec l ; Return to YPos
.animatePlayerY
    ld b, FRAMEOFF_NORMAL
    bit 4, a
    jr z, :+
        ld b, FRAMEOFF_STEP
:   ld a, Entity_Frame - Entity_YPos
    add a, l
    ld l, a
    ld [hl], b


.updateAllyPositions
    ld a, [wActivePlayer]
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ld hl, wPlayerArray + Entity_YPos
    add_r16_a hl
    ld d, [hl] ; Store active Y
    inc l
    ld e, [hl] ; Store active X

    ld c, PLAYER_OCTAVIA
.updateAllyPositionsLoop
    ld a, [wActivePlayer]
    cp a, c ; Skip the active player
    jr z, .updateAllyPositionsDecrement
    ld a, c
    call PlayerActivityCheck.waiting
    jr nz, .updateAllyPositionsDecrement ; Skip if the player is fully inactive

    push bc

    ld a, c
    add a, a ; a * 2
    inc a
    ld e, a ; distance is (ID*2 + 1) (max of 5, min of 1)
    ld a, c
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ld c, a
    ld b, 0
    call PlayerAIFollow

    pop bc

    ld a, c
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ld hl, wPlayerArray
    add_r16_a hl
    call MoveNoClip

.updateAllyPositionsDecrement
    inc c
    ld a, PLAYER_TIBER + 1
    cp a, c
    jr nz, .updateAllyPositionsLoop
    ret

; Looks up a position to see if it contains a transition tile, and transitions
; to the next screen if it does. Changing screens restarts the stack and main!
; @ a:  Current tile
ScreenTransitionCheck::
    ; Check if we are within the transition tiles.
    ASSERT TILEDATA_TRANSITION_LEFT - TILEDATA_TRANSITION_DOWN == 3
    ; We don't *actually* want this to be one lower, but the transition routine 
    ; expects DIR + 1
    sub a, TILEDATA_TRANSITION_DOWN - 1 
    ; And we *do* want this 1 higher, but we need to offset the - we just did.
    cp a, TILEDATA_TRANSITION_LEFT - TILEDATA_TRANSITION_DOWN + 2
    jr nc, .clearTransBuffer ; Clear wTransitionBuffer if we're not transitioning now.
    ld h, a
    ld a, [wTransitionBuffer]
    and a, a
    ret nz ; If the transition buffer is set, do not transition again
    ; UpdateActiveMap will set the transition buffer so that we don't rapidly switch rooms.
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
    call PlayerUpdateMapPosition
    ld a, SPAWN_ENTITIES
    call UpdateActiveMap
    call RenderPlayers
    ; End the frame early.
    ld sp, wStackOrigin
    jp Main.end
.clearTransBuffer
    xor a, a
    ld [wTransitionBuffer], a
    ret

; Checks if the tile in a is a Warp tile, and teleports to it if it is.
; @ a:  Current tile
WarpTileCheck::
    ; Check if we are within the transition tiles.
    ASSERT TILEDATA_WARP_3 - TILEDATA_WARP_0 == 3
    sub a, TILEDATA_WARP_0
    cp a, TILEDATA_WARP_3 - TILEDATA_WARP_0 + 1
    ret nc
    ld hl, wWarpData0
    add_r16_a hl
    ld a, [hli]
    ld [wActiveWorldMap], a
    ld a, [hli]
    ld [wWorldMapPositionY], a
    ld [wPlayerRoom.octavia], a
    ld [wPlayerRoom.poppy], a
    ld [wPlayerRoom.tiber], a
    ld a, [hli]
    ld [wWorldMapPositionX], a
    ld [wPlayerRoom.octavia + 1], a
    ld [wPlayerRoom.poppy + 1], a
    ld [wPlayerRoom.tiber + 1], a
    ld a, [hli]
    ld [wOctavia_YPos], a
    ld [wPoppy_YPos], a
    ld [wTiber_YPos], a
    ld a, [hli]
    ld [wOctavia_XPos], a
    ld [wPoppy_XPos], a
    ld [wTiber_XPos], a
    ld a, PALETTE_STATE_FADE_LIGHT
    ld [wPaletteState], a
    ld a, UPDATE_TILEMAP
    call UpdateActiveMap
    ; End the frame early.
    ld sp, wStackOrigin
    jp Main.end
    

PlayerUpdateMapPosition:
    ; Find an unreserved entity array.
    ld hl, wPlayerEntityArrayIndex
    ld bc, 3
  .loop
    ld a, [hli]
    cp 1
    adc a
    or b
    ld b, a
    dec c
    jr nz, .loop
    ld a, -1
  .count
    inc a
    srl b
    jr c, .count
    cp a, 2
    jr nc, .store
    ld a, -1 ; if the result is over 2, set the available index to -1
.store
    ldh [hAvailableEntityArray], a

    ld a, [wActivePlayer]
    ld b, a ; Save value of active player

    ld hl, wPlayerRoom - 2
    ld de, wPlayerWaitLink
    ld c, 3 + 1 
.waitLoop
    inc hl
    inc hl
.waitLoopShort
    dec c
    ret z
    ld a, [de]
    inc de
    cp a, b ; If the values don't match, check the next one.
    jr nz, .waitLoop
    ld a, [wWorldMapPositionY]
    ld [hli], a
    ld a, [wWorldMapPositionX]
    ld [hli], a
    jr .waitLoopShort


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
    ldh a, [hSCYBuffer]
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
    ldh a, [hSCXBuffer]
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

; Used to lookup the dialogue corresponding to the current room.
PlayerDialogueLookup:
    dw .octavia, .poppy, .tiber ; faster I guess?
.octavia
    far_pointer OctaviaGeneric
.poppy
    far_pointer PoppyGeneric
.tiber
    far_pointer TiberGeneric

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

; Player Max Health
wPlayerMaxHealth::
    .octavia::
        ds 1
    .poppy::
        ds 1
    .tiber::
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

; Used to check which entity array should be used by the current player, 
; allowing a room to retain it's state between player swaps. If two players are
; in the same room, these values must match. That means when a player is left 
; behind this value must update to an unused room, and when entering a room that
; a player has occupied, this value must update to that player's.
wPlayerEntityArrayIndex::
    .octavia::
        ds 1
    .poppy::
        ds 1
    .tiber::
        ds 1 

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

    dstruct Entity, wOctaviaSpell
    dstructs 2, Entity, wPoppyArrow

SECTION UNION "Volatile", HRAM
hAvailableEntityArray:
    ds 1