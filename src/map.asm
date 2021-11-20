INCLUDE "banks.inc"
INCLUDE "engine.inc"
INCLUDE "entity.inc"
INCLUDE "graphics.inc"
INCLUDE "items.inc"
INCLUDE "hardware.inc"
INCLUDE "map.inc"
INCLUDE "npc.inc"
INCLUDE "save.inc"
INCLUDE "optimize.inc"
INCLUDE "tiledata.inc"

; Keep these all in the same bank.
SECTION "Map Lookup", ROM0

; Updates the active map, loads map data, and runs initiallization scripts,
; such as spawning entities and updating player logic. Also clears player
; projectiles.
; @ a: Boolean flags - see map.inc
UpdateActiveMap::
	ld d, a ; Save inputs in `d` for a bit

    ld a, 1
    ld [wTransitionBuffer], a
    ldh [hRespawnEntitiesFlag], a

    ; If CAN_DESPAWN is set, check if the entity array is clear. if it is, set
    ; a flag that the given room has been cleared and should not respawn
    ; entities until the world is reloaded. If it is not set, clear the despawn
    ; map.
    bit CAN_DESPAWN_B, d
    jr z, .clearDespawn
    ld b, NB_ENTITIES
    ld hl, wEntityArray
.checkEntities
    ; If a data pointer is not zero, do not set the flag.
    ld a, [hli]
    or a, [hl]
    jr nz, .endDespawn
    ld a, sizeof_Entity - 1
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    dec b
    jr nz, .checkEntities
    ; If we make it here, set a flag in the despawn map.
    ld a, [wOldMapPosY]
    ld b, a
    swap b ; a * 16
    ld a, [wOldMapPosX]
    add a, b

    ld b, a
    ld hl, wDespawnMap
    call GetBitfieldMask
    or a, [hl]
    ld [hl], a
    jr .endDespawn

.clearDespawn
    xor a, a
    ld c, wDespawnMap.end - wDespawnMap
    ld hl, wDespawnMap
    call MemSetSmall

.endDespawn

    ld a, [wWorldMapPositionY]
    ld b, a
    swap b ; a * 16
    ld a, [wWorldMapPositionX]
    add a, b

    ld b, a
    ld hl, wDespawnMap
    call GetBitfieldMask
    and a, [hl]
    jr z, .noDespawn
    xor a, a
    ldh [hRespawnEntitiesFlag], a
.noDespawn

    ; Set the new old map so that we can check this next time :)
    ld a, [wWorldMapPositionX]
    ld [wOldMapPosX], a
    ld a, [wWorldMapPositionY]
    ld [wOldMapPosY], a

    ; Clear player spell
    ld hl, wOctaviaSpell
    ASSERT wOctaviaSpell + sizeof_Entity == wPoppyArrow0
    ld c, sizeof_Entity * 3
    xor a, a
    rst MemSetSmall
    ld [wOctaviaSpellActive], a

    ; Clear entity array
    ld c, sizeof_Entity * NB_ENTITIES
    ld hl, wEntityArray
    rst MemSetSmall

    ; Clear entity fields
    ld c, sizeof_Entity * NB_ENTITIES
    ld hl, wEntityFieldArray
    rst MemSetSmall

    ; Clear NPC array
    ld c, sizeof_NPC * NB_NPCS
    ld hl, wNPCArray
    rst MemSetSmall

    ; Clear collectables array
    ld c, sizeof_Collectable * NB_COLLECTABLES
    ld hl, wCollectablesArray
    rst MemSetSmall

	bit UPDATE_TILEMAP_B, d
	jp z, .skipNewTileMap

	; Is the screen off?
	ldh a, [rLCDC]
	ldh [hLCDCBuffer], a
	and a, a
	jr z, .waitSkip

	; Wait for the palettes to fade out
.waitPalFade
	halt
	ld a, [wPaletteState]
	and a, a
	jr nz, .waitPalFade

	di ; Take control of VBlank...
.waitVBlank
	ldh a, [rLY]
	cp a, 145
	jr c, .waitVBlank
	xor a, a
	ldh [rLCDC], a
	ldh [rIF], a
	ei
.waitSkip

	; Load tileset
    ld a, [wActiveWorldMap]
    ld b, a
    add a, b ; a * 2
    add a, b ; a * 3
    ; Add `a` to `MapLookup` and store in `hl`
    add a, LOW(MapLookup)
    ld l, a
    adc a, HIGH(MapLookup)
    sub a, l
    ld h, a

    ld a, [hli] ; Load target bank.
	ldh [hMapBankBuffer], a ; Save bank for later
    rst SwapBank

	ld a, [hli] ; Load first pointer byte
	ld h, [hl] ; Load second pointer byte
	ld l, a ; hl is now the mapdata pointer

	inc hl ; Skip Width
	inc hl ; Skip Size, now on tileset

	ld a, [hli] ; Load target bank.
	ld c, a
	ld a, [hli] ; Load first pointer byte
	ld e, a
	ld a, [hli] ; Load second pointer byte
	ld d, a ; de is now the tileset pointer
	push hl
        ; Swap to the bank of the source tiles.
		ld a, c
		rst SwapBank
        ; Set up arguments.
        ld h, d
        ld l, e
        ld bc, 128 * sizeof_TILE
		ld de, _VRAM_SHARED
		call VRAMCopy ; Set to static size & change to uncompressed copy. How to handle entities vs tiles?
	pop hl

    ; Return to map bank.
	ldh a, [hMapBankBuffer]
	rst SwapBank

    ldh a, [hSystem]
    and a, a
    jr z, .palSkip

        ld a, [hli] ; Load Palette Bank
        ld b, a
        ld a, [hli] ; Load Palette pointer low...
    push hl
        ld h, [hl]
        ld l, a

        ; Copy palettes to the fade target
        ld c, MAP_BKG_PALS * sizeof_PALETTE
        ld de, wBCPD
        call MemCopyFar
        ld c, MAP_OBJ_PALS * sizeof_PALETTE
        ; Skip the players' reserved palettes
        ld de, wOCPD + (sizeof_PALETTE * (8 - MAP_OBJ_PALS))
        call MemCopyFar

        lb bc, BANK(PalPlayers), sizeof_PALETTE * 4
        ld de, wOCPD
        ld hl, PalPlayers
        call MemCopyFar
    pop hl
    jr .palFinish

.palSkip
    inc hl
    inc hl
.palFinish
    inc hl ; The last read did not include a post-inc

	ld a, [hli] ; Load metatile size
	ld b, a
	ld a, [hli] ; Load metatile bank
	ldh [hMetatileBankBuffer], a

	; Definitions
		ld a, [hli] ; Wait to push to save on a single `inc`
	push hl
		ld h, [hl]
		ld l, a ; Load metatile defintions pointer
		ld c, b ; Restore size
		ld de, wMetatileDefinitions
		ldh a, [hMetatileBankBuffer]
		rst SwapBank
		rst MemCopySmall
	pop hl
	inc hl ; Seek to attributes

	ldh a, [hMapBankBuffer]
	rst SwapBank

	; Attributes
		ld a, [hli]
	push hl
		ld h, [hl]
		ld l, a ; Load metatile attributes pointer
		ld c, b ; Restore size
		ld de, wMetatileAttributes
		ldh a, [hMetatileBankBuffer]
		rst SwapBank
		rst MemCopySmall
	pop hl
	inc hl ; Seek to Data

	ldh a, [hMapBankBuffer]
	rst SwapBank

	; Data
	ld a, [hli] ; We don't need to save `hl` anymore
	ld h, [hl]
	ld l, a ; Load metatile attributes pointer
	ld c, b ; Restore size
	sra c ; size / 2
	sra c ; size / 4 !!!
	ld de, wMetatileData
	ldh a, [hMetatileBankBuffer]
	rst SwapBank
	rst MemCopySmall

    call GetActiveMap
	push bc ; Save the data pointer
		; Copy the map data
		ld bc, MAP_SIZE
		ld de, wMetatileMap
		call MemCopy
		call LoadMapData

    ld a, 1
    ldh [rVBK], a

    ld de, _SCRN0
    ld hl, wMetatileAttributes
    call LoadMetatileMap

    xor a, a
    ldh [rVBK], a

    ld hl, wMetatileDefinitions
    call LoadMetatileMap ; Force-load the entire map.
    call LoadMapData

    ld a, PALETTE_STATE_RESET
    ld [wPaletteState], a

	ldh a, [hLCDCBuffer]
	ldh [rLCDC], a

    jr .skipDoubleLoad

.skipNewTileMap

; Evaluate map data
	call GetActiveMap
	push bc ; Save the data pointer
		; Copy the map data
		ld bc, MAP_SIZE
		ld de, wMetatileMap
		call MemCopy
        ;call ScrollLoader
		call LoadMapData
.skipDoubleLoad
    pop hl
	ldh a, [hMapBankBuffer]
	rst SwapBank
.nextData
    ld a, [hli]
    add a, a
    add a, LOW(.jumpTable)
    ld e, a
    adc a, HIGH(.jumpTable)
    sub a, e
    ld d, a
    ld a, [de]
    inc de
    ld b, a
    ld a, [de]
    ld e, b
    ld d, a
    ; jp de
    push de
.knownRet
    ret

.jumpTable
    ASSERT MAPDATA_END == 0
    dw .knownRet
    ASSERT MAPDATA_ENTITY == 1
    dw MapdataEntity
    ASSERT MAPDATA_ALLY_MODE == 2
    dw MapdataAllyLogic
    ASSERT MAPDATA_SET_WARP == 3
    dw MapdataSetWarp
    ASSERT MAPDATA_NPC == 4
    dw MapdataNPC
    ASSERT MAPDATA_SET_RESPAWN == 5
    dw MapdataSetRespawn
    ASSERT MAPDATA_SET_DESTROY_TILE == 6
    dw MapdataSetDestroyTile
    ASSERT MAPDATA_SPAWN_ITEM == 7
    dw MapdataSpawnItem

MapdataEntity:
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a
    push hl
    ldh a, [hRespawnEntitiesFlag]
    and a, a
    call nz, SpawnEntity
    pop hl
    jr UpdateActiveMap.nextData

MapdataAllyLogic:
    ld a, [hli]
    ld [wAllyLogicMode], a
    jr UpdateActiveMap.nextData

MapdataSetWarp:
    ld a, [hli]
    ldh [hWarpDataIndex], a ; Save the tile index.
    ; Offset to de for the memcopy
    ; Add `a` to `wWarpData0` and store in `de`
    add a, LOW(wWarpData0)
    ld e, a
    adc a, HIGH(wWarpData0)
    sub a, e
    ld d, a

    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    push hl
    swap b
    ld a, b
    ; Add `a` to `wMapData` and store in `hl`
    add a, LOW(wMapData)
    ld l, a
    adc a, HIGH(wMapData)
    sub a, l
    ld h, a
    ld a, c
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ldh a, [hWarpDataIndex]
    add a, TILEDATA_WARPS
    ld [hl], a
    pop hl
    ld c, sizeof_WarpData
    rst MemCopySmall
    jr UpdateActiveMap.nextData

MapdataNPC:
    ld a, [hli]
    ldh [hNPCIndex], a
    ASSERT sizeof_NPC == 8
    add a, a ; a * 2
    add a, a ; a * 4
    add a, a ; a * 8

    ; Load NPC array
    ASSERT LOW(wNPCArray) == 0
    ld e, a
    ld d, HIGH(wNPCArray)

    ld c, sizeof_NPC
    rst MemCopySmall

    ; Switch to using `de`, the location of the entity in RAM. This allows us to
    ; only use `e` for seeking, and not worry about correcting `hl`

    ld a, NPC_Position - (NPC_Script + 2)
    add a, e
    ld e, a

    ; Lookup tile based on X, Y locations
    ; Load X
    ld a, [de]
    and a, $0F

    ; Add X to wMapData, store in `bc`
    add a, LOW(wMapData)
    ld c, a
    adc a, HIGH(wMapData)
    sub a, c
    ld b, a

    ; Now load Y
    ld a, [de]
    and a, $F0 ; Already convieniently *16!

    ; Add Y to `bc`
    add a, c
    ld c, a
    adc a, b
    sub a, c
    ld b, a

    ; Seek down to the ID
    ldh a, [hNPCIndex]
    add a, TILEDATA_NPC_0
    ld [bc], a ; Load an NPC tile onto the map.

    jp UpdateActiveMap.nextData

MapdataSetRespawn:
    ld de, wRespawnPoint
    ld a, [wActiveWorldMap]
    ld [de], a
    inc de
    ld a, [wWorldMapPositionX]
    ld [de], a
    inc de
    ld a, [wWorldMapPositionY]
    ld [de], a
    inc de
    ld c, sizeof_RespawnPoint - 3
    rst MemCopySmall
    jp UpdateActiveMap.nextData

MapdataSetDestroyTile:
    ld a, [hli]
    ld [wDestroyedMapTile], a
    jp UpdateActiveMap.nextData

MapdataSpawnItem:
    push hl
        inc hl
        inc hl
        inc hl
        inc hl
        ld b, [hl]
        ld hl, wBitfield
        call GetBitfieldMask
        and a, [hl]
    pop hl
    ; If the flag is set, don't spawn this item.
    jr nz, .flagSet
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld e, a
    push hl
        call SpawnCollectable
    ; SpawnCollectable returns a pointer to the collectable in hl, so we'll
    ; restore the data pointer into de.
    pop de
    ; hl is currently the collection flag.
    ; However, if `l & %111 == 0`, then SpawnCollectable failed. Check for this
    ; and exit if needed.
    ld a, l
    and a, %111
    jr z, .fail
        ld a, [de]
        ld [hl], a
.fail
    inc de
    ld h, d
    ld l, e
    jp UpdateActiveMap.nextData

.flagSet
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    jp UpdateActiveMap.nextData

; Returns the active Map in `hl`, and its data in `bc`.
; Used to copy map into wMetatileMap and spawn entities/run scripts.
GetActiveMap::
    ld a, [wActiveWorldMap]
    ld b, a
    add a, b ; a * 2
    add a, b ; a * 3
    ; Add `a` to `MapLookup` and store in `hl`
    add a, LOW(MapLookup)
    ld l, a
    adc a, HIGH(MapLookup)
    sub a, l
    ld h, a

    ld a, [hli] ; Load target bank.
	ldh [hMapBankBuffer], a ; Save bank for later
    rst SwapBank
    ld a, [hli] ; Load first pointer byte
    ld h, [hl] ; Load second pointer byte
    ld l, a ; hl is now the map pointer

    ld a, [hli] ; Load and skip the width byte.
    ld c, a
    ld a, [hl] ; Load the size byte
    ld d, a

    ld a, MapData_Layout - MapData_Size ; Skip to the layout
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

    ld a, [wWorldMapPositionX]
    add a, a ; Pointers are 2 bytes long.
    ; Add X offset.
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ld a, [wWorldMapPositionY]
    and a, a ; If y = 0 just skip.
    jr z, .skipY
    ld b, a
    ld a, c
.multLoop ; Multiply c (width) * b (ypos) and add the result to hl
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    dec b
    jr nz, .multLoop
.skipY ; This is dumb

    ld b, h
    ld c, l
    ld a, d ; Restore map size
    ; Offset to find the map data
    ; Add `a` to `bc`
    add a, c
    ld c, a
    adc a, b
    sub a, c
    ld b, a

    ld a, [bc] ; Load first pointer byte
    ld d, a
    inc bc
    ld a, [bc] ; Load second pointer byte
    ld c, d
    ld b, a ; bc is now the map data pointer

    ld a, [hli] ; Load first pointer byte
    ld h, [hl] ; Load second pointer byte
    ld l, a ; hl is now the map pointer
    ; hl now points to the correct map.
    ; bc is the map's data.
    ret

; Used to reload the active map's tiles if they were changed for any reason.
ReloadMapGraphics::
    ldh a, [hCurrentBank]
    push af

    ld a, [wActiveWorldMap]
    ld b, a
    add a, b ; a * 2
    add a, b ; a * 3
    ; Add `a` to `MapLookup` and store in `hl`
    add a, LOW(MapLookup)
    ld l, a
    adc a, HIGH(MapLookup)
    sub a, l
    ld h, a

    ld a, [hli]
    ldh [hMapBankBuffer], a
    rst SwapBank

    ld a, [hli]
    ld h, [hl]
    ld l, a

    ; Seek to tiles and reload them
    inc hl
    inc hl
    ld a, [hli]
    ld c, a
    ld a, [hli]

    push hl
        ld h, [hl]
        ld l, a
        ld a, c
        rst SwapBank
        ld bc, 128 * sizeof_TILE
        ld de, _VRAM_SHARED
        call VRAMCopy

        ldh a, [hMapBankBuffer]
        rst SwapBank
    pop hl

    ldh a, [hSystem]
    and a, a
    jr z, .cgbSkip

    inc hl

    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, b
    rst SwapBank

    ld c, MAP_BKG_PALS * sizeof_PALETTE
    ld de, wBCPD
    rst MemCopySmall
    ld c, MAP_OBJ_PALS * sizeof_PALETTE
    ld de, wOCPD + (sizeof_PALETTE * (8 - MAP_OBJ_PALS)) ; Skip the players' reserved palettes
    rst MemCopySmall

    lb bc, BANK(PalPlayers), sizeof_PALETTE * 4
    ld de, wOCPD
    ld hl, PalPlayers
    call MemCopyFar

.cgbSkip

    ld a, PALETTE_STATE_RESET
    ld [wPaletteState], a

    ; Restore bank
    pop af
    rst SwapBank
    ret

; Used to check which World Map we're referencing (Overworld, Dungeon, etc...)
; Maximum of 85 Maps, since 256/3 = 85
MapLookup:
    ; World Map 0
    far_pointer OverworldMap
    far_pointer xBeach
    far_pointer xCave

PanoramaLookup::
    ; World Map 0
    far_pointer xNightPanorama
    far_pointer BeachPanorama
    far_pointer xNightPanorama

SECTION "Active Map Variables", WRAM0

; Which map are we on?
wActiveWorldMap::
    DS 1

; How many tiles have been loaded so far?
wTileLoadingProgress::
    DS 1

; Which room are we in?
wWorldMapPositionX::
    DS 1

wWorldMapPositionY::
    DS 1

; Used for setting the despawn flag of the last map we were in.
wOldMapPosX: DB
wOldMapPosY: DB

    dstructs 4, WarpData, wWarpData

wDestroyedMapTile:: DB

; Bitfield used to keep track of which rooms have despawned their entities.
wDespawnMap:
    DS 16 * 16 / 8
.end

SECTION UNION "Volatile", HRAM
; Set if this room has been despawned.
hRespawnEntitiesFlag:
    DS 1
hWarpDataIndex:
hNPCIndex:
hLCDCBuffer:
    DS 1
hMapBankBuffer:
	DS 1
hMetatileBankBuffer:
	DS 1
