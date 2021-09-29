
INCLUDE "include/banks.inc"
INCLUDE "include/enum.inc"
INCLUDE "include/structs.inc"

DEF MAP_SIZE EQU 16 * 16

DEF MAP_BKG_PALS EQU 6
DEF MAP_OBJ_PALS EQU 4

; UpdateActiveMapFlags
DEF SPAWN_ENTITIES EQU 1
DEF UPDATE_TILEMAP EQU 2

DEF SPAWN_ENTITIES_B EQU 0
DEF UPDATE_TILEMAP_B EQU 1

; Defines a new map struct, leaving room at the bottom for the layout and data
; @ define_map width, height, tile_amount, pb16_tileset, metatiles
MACRO define_map
    ; MapData_Width
.width
    db (2) * \1
    ; MapData_Size
.size
    db (2 * \1) * \2
    ; MapData_TilesetSize
.tilesetSize
    db \3
    ; MapData_TilesetBank, MapData_Tileset
.tileset
    far_pointer \4
    ; MapData_PalettesBank, MapData_Palettes
.palettes
    far_pointer \5
    ; MapData_MetatileSize
.metatileSize
    db \6.end - \6
    ; MapData_MetatileBank
.metatileBank
    db BANK(\6)
    ; MapData_MetatileDefinitions
.metatileDefinitions
    dw \6.definitions
    ; MapData_MetatileAttributes
.metatileAttributes
    dw \6.attributes
    ; MapData_MetatileData
.metatileData
    dw \6.data
ENDM

; Ends a mapdata definition
MACRO end_mapdata
    db MAPDATA_END
ENDM

; Spawns entity when entering a given room
; @ create_entity EntityPointer, PosY, PosX
MACRO create_entity
    IF _NARG != 3
        FAIL "Expected 3 args."
    ENDC
    db MAPDATA_ENTITY
    dw \1
    db \2, \3
ENDM
DEF sizeof_create_entity EQU 4

; Sets the Ally logic for the room. Optional, but should rarely go unused.
; @ ally_logic ALLY_MODE
MACRO ally_mode
    IF _NARG != 1
        FAIL "Expected 1 arg."
    ENDC
    db MAPDATA_ALLY_MODE
    db \1
ENDM

; Stores a WarpData in ram for the given tile.
; @ set_warp Index, TilePosY, TilePosX, Map, RoomY, RoomX, ExitY, ExitX
MACRO set_warp
    IF _NARG != 8
        FAIL "Expected 8 args."
    ELIF \1 > 3
        FAIL "Warp tile index cannot be greater than 3."
    ENDC
    db MAPDATA_SET_WARP
    db \1 ; Index
    db \2, \3 ; Tile Position
    db \4, \5, \6, \7, \8 ; Warp Data
ENDM

; Spawn an NPC when entering a given room.
; @ create_npc ID, Metasprites, Direction, Y, X, Script
MACRO create_npc
    IF _NARG != 6
        FAIL "Expected 8 args."
    ELIF \1 > 3
        FAIL "Entity ID cannot be greater than 3."
    ENDC
    db MAPDATA_NPC
    db \1 ; ID
    db BANK(\2)
    dw \2 ; Metasprites
    db \3 ; Direction
    db (\5 << 4) | \4 ; X and Y
    db BANK(\6)
    dw \6 ; Script
ENDM

MACRO set_respawn
    ASSERT _NARG == sizeof_RespawnPoint && sizeof_RespawnPoint == 9
    db MAPDATA_SET_RESPAWN
    FOR i, _NARG
        db \1
        SHIFT 1
    ENDR
ENDM

; Macro Data enumerations
    start_enum MAPDATA
        enum END
        enum ENTITY
        enum ALLY_MODE
        enum SET_WARP
        enum NPC
        enum SET_RESPAWN
    end_enum

; Map enumerations
    start_enum MAP
        enum OVERWORLD
        enum BEACH
    end_enum

    struct MapData
        bytes 1, Width
        bytes 1, Size

        bytes 1, TilesetSize ; How many tiles?
        bytes 1, TilesetBank
        words 1, Tileset

        bytes 1, PalettesBank
        words 1, Palettes

        bytes 1, MetatileSize ; How large are the metatiles? Data will be /4
        bytes 1, MetatileBank
        words 1, MetatileDefinitions
        words 1, MetatileAttributes
        words 1, MetatileData

        dunion Layout
    end_struct

; Used to set up targets for warp tiles.
    struct WarpData
        bytes 1, Map
        bytes 1, YRoom
        bytes 1, XRoom
        bytes 1, YPos
        bytes 1, XPos
    end_struct

    struct Panorama
        bytes 1, DMGSize
        words 1, DMGTiles
        words 1, DMGMap

        bytes 1, CGBSize
        words 1, CGBTiles
        words 1, CGBMap
        words 1, Attributes
        words 1, Palettes
    end_struct