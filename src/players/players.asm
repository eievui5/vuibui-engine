INCLUDE "engine.inc"
INCLUDE "entity.inc"
INCLUDE "hardware.inc"
INCLUDE "map.inc"
INCLUDE "npc.inc"
INCLUDE "players.inc"
INCLUDE "stdopt.inc"
INCLUDE "tiledata.inc"

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
    rst SwapBank
    call OctaviaPlayerLogic
    ld a, [wOctaviaSpellActive]
    and a, a
    ld a, BANK(OctaviaSpellLogic)
    rst SwapBank
    call nz, OctaviaSpellLogic

.checkPoppy
    ld a, PLAYER_POPPY
    call PlayerActivityCheck.disabled ; If rooms do not match or player is disabled, skip.
    jr nz, .checkTiber
    ld a, BANK(PoppyPlayerLogic)
    rst SwapBank
    call PoppyPlayerLogic
    ld a, [wPoppyActiveArrows]
    and a, a
    jr z, .checkTiber
    ; Just an unrolled entity handler for arrows...
    ld a, BANK(PoppyArrowLogic)
    rst SwapBank
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
    rst SwapBank
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
    ; Add `a` to `wPlayerWaitLink` and store in `hl`
    add a, LOW(wPlayerWaitLink)
    ld l, a
    adc a, HIGH(wPlayerWaitLink)
    sub a, l
    ld h, a
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
    ; Add `a` to `wPlayerWaitLink` and store in `hl`
    add a, LOW(wPlayerWaitLink)
    ld l, a
    adc a, HIGH(wPlayerWaitLink)
    sub a, l
    ld h, a
    ld a, [wActivePlayer]
    cp a, [hl]
    ret nz
    ld a, b
.disabled::
    ; Is player enabled?
    ld b, a
    ; Add `a` to `wPlayerDisabled` and store in `hl`
    add a, LOW(wPlayerDisabled)
    ld l, a
    adc a, HIGH(wPlayerDisabled)
    sub a, l
    ld h, a
    ld a, [hl]
    and a, a
    ret nz
    ld a, b
.room::
    add a, a
    ; Add `a` to `wPlayerRoom` and store in `hl`
    add a, LOW(wPlayerRoom)
    ld l, a
    adc a, HIGH(wPlayerRoom)
    sub a, l
    ld h, a
    ld a, [wWorldMapPositionY]
    cp a, [hl]
    ret nz ; If the rooms match, call normally.
    inc hl
    ld a, [wWorldMapPositionX]
    cp a, [hl]
    ret ; If the rooms match, call normally.

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

; Check if a player is trying to talk to an NPC. If this succeeds a super return
; is performed, and player logic will end.
; @ `hl`: Pointer to Player.
NPCInteractionCheck::
    ldh a, [hNewKeys]
    bit PADB_A, a
    ret z
    call GetEntityTargetPosition
    ; Add positions to wMapData
    ; Divide X by 16
    ld a, e
    ; Weird offset! I clearly screwed up entity positions...
    sub a, $F
    and a, $F0
    swap a
    ; Add X to wMapData, store in `bc`
    add a, LOW(wMapData)
    ld c, a
    adc a, HIGH(wMapData)
    sub a, c
    ld b, a

    ; Mask out lower bits (divide by 16, then mult by 16)
    ld a, d
    ; Weird offset! I clearly screwed up entity positions...
    sub a, $10
    and a, $F0

    ; Add Y to `bc`
    add a, c
    ld c, a
    adc a, b
    sub a, c
    ld b, a

    ; Check the tile we found
    ld a, [bc]
    ; Offset to NPC tiles
    sub a, TILEDATA_NPC_0
    ret c ; If a < TILEDATA_NPC_0
    cp a, TILEDATA_NPC_3 + 1
    ret nc ; If a > TILEDATA_NPC_3

    ASSERT sizeof_NPC == 8
    add a, a ; a * 2
    add a, a ; a * 4
    add a, a ; a * 8

    ; Grab that NPC's script
    add a, LOW(wNPCArray + NPC_ScriptBank)
    ld l, a
    ld h, HIGH(wNPCArray + NPC_ScriptBank)

    ld c, 3
    ld de, wActiveScriptPointer
    rst MemCopySmall

    pop hl ; Super ret !
    ret

; Check if the players are trying to talk. If this succeeds a super return is
; performed, and player logic will end.
; @ `hl`: Pointer to Player.
PlayerInteractionCheck::
    ldh a, [hNewKeys]
    bit PADB_A, a
    ret z
    call GetEntityTargetPosition
    call CheckAllyCollision
    cp a, $FF
    ret z
    add a, a ; a * 2 (Pointer)
    ; Add `a` to `PlayerDialogueLookup` and store in `hl`
    add a, LOW(PlayerDialogueLookup)
    ld l, a
    adc a, HIGH(PlayerDialogueLookup)
    sub a, l
    ld h, a
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ; `hl` is now the target player's dialogue lookup table

    ; Load current dialogue mode and add to table

    ld c, 3 ; bank + pointer
    ld de, wActiveScriptPointer
    rst MemCopySmall

    pop hl ; Super ret!
    ret

; Returns the entity position offset by their facing direction in `de` (Y, X)
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
    ; Add `a` to `wPlayerArray + Entity_YPos` and store in `hl`
    add a, LOW(wPlayerArray + Entity_YPos)
    ld l, a
    adc a, HIGH(wPlayerArray + Entity_YPos)
    sub a, l
    ld h, a
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
    cp a, 56 ; stops on the third tile
    jr z, .updateAllyPositions ; Are we already there?
    inc [hl] ; No? Then move down
    jr .animatePlayerY
.up
    ld a, [hl]
    cp a, -24 ; Stop on the first tile
    jr z, .updateAllyPositions ; Are we already there?
    dec [hl] ; No? Then move up
    jr .animatePlayerY
.right
    ld a, [hl]
    cp a, 49 ; Stop on the first tile
    jr z, .updateAllyPositions ; Are we already there?
    inc [hl] ; No? Then move right
    jr .animatePlayerX
.left
    ld a, [hl]
    cp a, -31 ; Stop on the first tile
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
    ; Add `a` to `wPlayerArray + Entity_YPos` and store in `hl`
    add a, LOW(wPlayerArray + Entity_YPos)
    ld l, a
    adc a, HIGH(wPlayerArray + Entity_YPos)
    sub a, l
    ld h, a
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
    ; Add `a` to `wPlayerArray` and store in `hl`
    add a, LOW(wPlayerArray)
    ld l, a
    adc a, HIGH(wPlayerArray)
    sub a, l
    ld h, a
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
    cp a, TILEDATA_TRANSITION_LEFT - TILEDATA_TRANSITION_DOWN + 2 ; + 1
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
    dec a ; and a, a
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
    ; Add `a` to `wWarpData0` and store in `hl`
    add a, LOW(wWarpData0)
    ld l, a
    adc a, HIGH(wWarpData0)
    sub a, l
    ld h, a
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
    fall .store
.store
    ; Add `a` to `wPlayerWaitLink` and store in `hl`
    add a, LOW(wPlayerWaitLink)
    ld l, a
    adc a, HIGH(wPlayerWaitLink)
    sub a, l
    ld h, a
    ld a, [wActivePlayer]
    ld [hl], a
    ret

PlayerCameraInterpolation::
    ; Offset to the active player.
    ld a, [wActivePlayer]
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ; Add `a` to `wPlayerArray + Entity_YPos` and store in `de`
    add a, LOW(wPlayerArray + Entity_YPos)
    ld e, a
    adc a, HIGH(wPlayerArray + Entity_YPos)
    sub a, e
    ld d, a

    ; Y Interp
    ldh a, [hSCYBuffer]
    ld b, a
    ld a, [de]
    sub a, 11
    sub a, 80 - 11
    jr nc, :+
        xor a, a
:   sub a, b
    rra ; divide by 8
    sra a
    sra a
    ld c, a
    add a, b
    cp a, 256 - 144 + 16 + 1 ; Is -A past the screen bounds?
    jr nc, .x
:   ldh [hSCYBuffer], a

.x  ldh a, [hSCXBuffer]
    ld b, a
    inc de ; Seek to X
    ld a, [de]
    sub a, 11
    sub a, 72 + 8 - 11
    jr nc, :+
        xor a, a
:   sub a, b
    rra ; divide by 8, conserve the sign
    sra a
    sra a
    add a, b
    cp a, 256 - 160 + 1 ; Is A past the screen bounds?
    ret nc
    ldh [hSCXBuffer], a
    ld a, e
    ret

; Checks if the active player is colliding with `de`. Returns a pointer
; to the detected player in `hl`, $0000 if no player was found.
; @ de: Check Position (Y, X)
CheckPlayerCollision::
    ld h, HIGH(wPlayerArray)
    ASSERT sizeof_Entity == 16
    ld a, [wActivePlayer]
    swap a
    ld l, a
    jp CheckEntityCollision

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
    DW .octavia, .poppy, .tiber ; faster I guess?
.octavia
    far_pointer OctaviaGeneric
.poppy
    far_pointer PoppyGeneric
.tiber
    far_pointer TiberGeneric

SECTION "Player Variables", WRAM0

wPlayerVariables::

; The Character currently being controlled by the player. Used as an offset.
wActivePlayer::
    DS 1

; Make sure we only transition upon *entering* a transition tile.
wTransitionBuffer::
    DS 1

; Used to adjust entity logic based on the layout of the current room
wAllyLogicMode::
    DS 1

; Player Max Health
wPlayerMaxHealth::
    .octavia::
        DS 1
    .poppy::
        DS 1
    .tiber::
        DS 1

; Player disablers
wPlayerDisabled::
    .octavia::
        DS 1
    .poppy::
        DS 1
    .tiber::
        DS 1

; Player waiting and linking. If the value does not match that of the active
; player they should wait. This is important because it means switching players
; will follow each other independantly; switching from an active player to a
; waiting player will cause the other group to wait.
wPlayerWaitLink::
    .octavia::
        DS 1
    .poppy::
        DS 1
    .tiber::
        DS 1

; Player world map Position. Used to keep track of which room an inactive
; player is waiting in. Y, X order.
wPlayerRoom::
    .octavia::
        DS 2
    .poppy::
        DS 2
    .tiber::
        DS 2

; The currently equipped items.
; Lower Nibble = A, Upper Nibble = B
wPlayerEquipped::
    .octavia::
        DS 1
    .poppy::
        DS 1
    .tiber::
        DS 1

; The player's unlocked items.
; @ bit 0: Item 0
; @ bit 1: Item 1
; @ bit 2: Item 2
; @ bit 3: Item 3
wItems::
    .octavia::
        DS 1
    .poppy::
        DS 1
    .tiber::
        DS 1

wPlayerVariablesEnd::

SECTION "Player Array", WRAM0, ALIGN[8]
wPlayerArray::
    dstruct Entity, wOctavia
    dstruct Entity, wPoppy
    dstruct Entity, wTiber

    dstruct Entity, wOctaviaSpell
    dstructs 2, Entity, wPoppyArrow

SECTION UNION "Volatile", HRAM
hLastBank:
    DS 1