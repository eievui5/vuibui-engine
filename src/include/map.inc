
INCLUDE "banks.inc"
INCLUDE "enum.inc"
INCLUDE "structs.inc"

DEF MAP_SIZE EQU 16 * 16

DEF MAP_BKG_PALS EQU 6
DEF MAP_OBJ_PALS EQU 4

; UpdateActiveMapFlags
DEF UPDATE_TILEMAP EQU 1
DEF CAN_DESPAWN EQU 2

DEF UPDATE_TILEMAP_B EQU 0
DEF CAN_DESPAWN_B EQU 1

; Defines a new map struct, leaving room at the bottom for the layout and data
; @ define_map width, height, tileset, palettes, metatiles
MACRO define_map
    ASSERT _NARG == 5, "Expected 5 arguments!"
    ; MapData_Width
.width
    DB (2) * \1
    ; MapData_Size
.size
    DB (2 * \1) * \2
    ; MapData_TilesetBank, MapData_Tileset
.tileset
    far_pointer \3
    ; MapData_PalettesBank, MapData_Palettes
.palettes
    far_pointer \4
    ; MapData_MetatileSize
.metatileSize
    DB \5.end - \5
    ; MapData_MetatileBank
.metatileBank
    DB BANK(\5)
    ; MapData_MetatileDefinitions
.metatileDefinitions
    DW \5.definitions
    ; MapData_MetatileAttributes
.metatileAttributes
    DW \5.attributes
    ; MapData_MetatileData
.metatileData
    DW \5.data
ENDM

; Ends a mapdata definition
MACRO end_mapdata
    DB MAPDATA_END
ENDM

; Spawns entity when entering a given room
; @ create_entity EntityPointer, PosY, PosX
MACRO create_entity
    IF _NARG != 3
        FAIL "Expected 3 args."
    ENDC
    DB MAPDATA_ENTITY
    DW \1
    DB \2, \3
ENDM
DEF sizeof_create_entity EQU 4

; Sets the Ally logic for the room. Optional, but should rarely go unused.
; @ ally_logic ALLY_MODE
MACRO ally_mode
    IF _NARG != 1
        FAIL "Expected 1 arg."
    ENDC
    DB MAPDATA_ALLY_MODE
    DB \1
ENDM

; Stores a WarpData in ram for the given tile.
; @ set_warp Index, TilePosY, TilePosX, Map, RoomY, RoomX, ExitY, ExitX
MACRO set_warp
    IF _NARG != 8
        FAIL "Expected 8 args."
    ELIF \1 > 3
        FAIL "Warp tile index cannot be greater than 3."
    ENDC
    DB MAPDATA_SET_WARP
    DB \1 ; Index
    DB \2, \3 ; Tile Position
    DB \4, \5, \6, \7, \8 ; Warp Data
ENDM

; Spawn an NPC when entering a given room.
; @ create_npc ID, Metasprites, Direction, Y, X, Script
MACRO create_npc
    ASSERT _NARG == 6, "Expected 6 args."
    ASSERT !(\1 > 3), "Entity ID cannot be greater than 3."
    DB MAPDATA_NPC
    DB \1 ; ID
    DB BANK(\2)
    DW \2 ; Metasprites
    DB \3 ; Direction
    DB (\5 << 4) | \4 ; X and Y
    DB BANK(\6)
    DW \6 ; Script
ENDM

MACRO set_respawn
    ASSERT _NARG == (sizeof_RespawnPoint - 3) && sizeof_RespawnPoint == 9
    DB MAPDATA_SET_RESPAWN
    FOR i, _NARG
        DB \1
        SHIFT 1
    ENDR
ENDM

MACRO set_destroy_tile
    ASSERT _NARG == 1, "Expected 1 arg."
    DB MAPDATA_SET_DESTROY_TILE, \1
ENDM

MACRO spawn_item ; Collectable pointer, Y, X, [flag]
    ASSERT _NARG == 3 || _NARG == 4, "Expected 3 or 4 arguments."
    DB MAPDATA_SPAWN_ITEM
    DW \1
    DB \2, \3
    IF _NARG == 4
        DB \4
    ELSE
        DB 0
    ENDC
ENDM

; Macro Data enumerations
    start_enum MAPDATA
        enum END
        enum ENTITY
        enum ALLY_MODE
        enum SET_WARP
        enum NPC
        enum SET_RESPAWN
        enum SET_DESTROY_TILE
        enum SPAWN_ITEM
    end_enum

; Map enumerations
    start_enum MAP
        enum OVERWORLD
        enum BEACH
    end_enum

    struct MapData
        bytes 1, Width
        bytes 1, Size

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
        words 1, DMGTiles
        words 1, DMGMap

        words 1, CGBTiles
        words 1, CGBMap
        words 1, Attributes
        words 1, Palettes
    end_struct