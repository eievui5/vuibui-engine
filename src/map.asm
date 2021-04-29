INCLUDE "include/banks.inc"
INCLUDE "include/bool.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/map.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/switch.inc"
INCLUDE "include/tiledata.inc"

; Keep these all in the same bank.
SECTION "Map Lookup", ROM0

; Updates the active map, loads map data, and runs initiallization scripts, 
; such as spawning entities and updating player logic. Also clears player
; projectiles.
; @ a: Boolean flags - see map.inc
UpdateActiveMap::
	ld d, a ; Save inputs in `d` for a bit

	bit SPAWN_ENTITIES_B, d
	jr z, :+
	ld a, TRUE
    ldh [hRespawnEntitiesFlag], a ; Any non-zero value is enough
:
    ; Clear player spell
    ld hl, wOctaviaSpell
    ASSERT wOctaviaSpell + sizeof_Entity == wPoppyArrow0
    ld bc, sizeof_Entity * 3
    xor a, a
    call memset
    ld [wOctaviaSpellActive], a
    
    ; Clear entity array
    ld bc, sizeof_Entity * MAX_ENTITIES
    ld hl, wEntityArray
    call memset

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
    ld hl, MapLookup
    add_r16_a hl

    ld a, [hli] ; Load target bank.
	ldh [hMapBankBuffer], a ; Save bank for later
    swap_bank

	ld a, [hli] ; Load first pointer byte
	ld h, [hl] ; Load second pointer byte
	ld l, a ; hl is now the mapdata pointer

	inc hl ; Skip Width
	inc hl ; Skip Size, now on tileset

	ld a, [hli] ; Load no. of tiles
	ld b, a
	ld a, [hli] ; Load target bank. 
	ld c, a
	ld a, [hli] ; Load first pointer byte
	ld e, a
	ld a, [hli] ; Load second pointer byte
	ld d, a ; de is now the tileset pointer
	push hl
		ld hl, VRAM_TILES_SHARED
		ld a, c
		swap_bank
		call pb16_unpack_block
	pop hl

	ldh a, [hMapBankBuffer]
	swap_bank

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
		swap_bank
		rst memcopy_small
	pop hl
	inc hl ; Seek to attributes

	ld a, [hMapBankBuffer]
	swap_bank

	; Attributes
		ld a, [hli]
	push hl
		ld h, [hl]
		ld l, a ; Load metatile attributes pointer
		ld c, b ; Restore size
		ld de, wMetatileAttributes
		ldh a, [hMetatileBankBuffer]
		swap_bank
		rst memcopy_small
	pop hl
	inc hl ; Seek to Data

	ld a, [hMapBankBuffer]
	swap_bank

	; Data
	ld a, [hli] ; We don't need to save `hl` anymore
	ld h, [hl]
	ld l, a ; Load metatile attributes pointer
	ld c, b ; Restore size
	sra c ; size / 2
	sra c ; size / 4 !!!
	ld de, wMetatileData
	ldh a, [hMetatileBankBuffer]
	swap_bank
	rst memcopy_small

	ld a, [hLCDCBuffer]
	ldh [rLCDC], a

.skipNewTileMap

; Evaluate map data
	call GetActiveMap
	push bc ; Save the data pointer
		; Copy the map data
		ld bc, MAP_SIZE
		ld de, wMetatileMap
		call memcopy
		call LoadMapData
    pop hl
	ldh a, [hMapBankBuffer]
	swap_bank
.nextData
    ld a, [hli]
    ASSERT MAPDATA_END == 0
    and a, a
    ret z
    ASSERT MAPDATA_ENTITY == 1
    dec a
    jr z, MapdataEntity
    ASSERT MAPDATA_ALLY_MODE == 2
    dec a
    jr z, MapdataAllyLogic
    ASSERT MAPDATA_SET_WARP == 3
    dec a
    jr z, MapdataSetWarp

MapdataEntity:
    ldh a, [hRespawnEntitiesFlag]
    and a, a
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a
    push hl
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
    ld de, wWarpData0
    add_r16_a de ; Offset to de for the memcopy
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    push hl
    ld hl, wMapData
    swap b
    ld a, b
    add_r16_a hl
    ld a, c
    add_r16_a hl
    ldh a, [hWarpDataIndex]
    add a, TILEDATA_WARPS
    ld [hl], a
    pop hl
    ld c, sizeof_WarpData
    rst memcopy_small
    jr UpdateActiveMap.nextData

; Returns the active Map in `hl`, and its data in `bc`.
; Used to copy map into wMetatileMap and spawn entities/run scripts.
GetActiveMap::
    ld a, [wActiveWorldMap]
    ld b, a
    add a, b ; a * 2
    add a, b ; a * 3
    ld hl, MapLookup
    add_r16_a hl

    ld a, [hli] ; Load target bank.
	ldh [hMapBankBuffer], a ; Save bank for later
    swap_bank
    ld a, [hli] ; Load first pointer byte
    ld h, [hl] ; Load second pointer byte
    ld l, a ; hl is now the map pointer

    ld a, [hli] ; Load and skip the width byte.
    ld c, a
    ld a, [hl] ; Load the size byte
    ld d, a

    ld a, MapData_Layout - MapData_Size ; Skip to the layout
    add_r16_a hl

    ld a, [wWorldMapPositionX]
    add a, a ; Pointers are 2 bytes long.
    add_r16_a hl ; Add X offset.
    ld a, [wWorldMapPositionY]
    and a, a ; If y = 0 just skip.
    jr z, .skipY
    ld b, a 
    ld a, c 
.multLoop ; Multiply c (width) * b (ypos) and add the result to hl
    add_r16_a hl
    dec b
    jr nz, .multLoop
.skipY ; This is dumb

    ld b, h
    ld c, l
    ld a, d ; Restore map size
    add_r16_a bc ; Offset to find the map data
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

; Used to check which World Map we're referencing (Overworld, Dungeon, etc...)
; Maximum of 85 Maps, since 256/3 = 85
MapLookup:
    ; World Map 0
    far_pointer OverworldMap

SECTION "Active Map Variables", WRAM0

; Which map are we on?
wActiveWorldMap:: 
    ds 1

; How many tiles have been loaded so far?
wTileLoadingProgress::
    ds 1

; Which room are we in?
wWorldMapPositionX:: 
    ds 1

wWorldMapPositionY:: 
    ds 1

    dstructs 4, WarpData, wWarpData

SECTION UNION "Volatile", HRAM
; Boolean value, set when entities should be respawned
hRespawnEntitiesFlag:
    ds 1
hWarpDataIndex: 
hLCDCBuffer:
    ds 1
hMapBankBuffer:
	ds 1
hMetatileBankBuffer:
	ds 1