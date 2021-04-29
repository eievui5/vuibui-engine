INCLUDE "include/banks.inc"
INCLUDE "include/map.inc"

; TODO: Remove hard-coded bank test
SECTION "Overworld Map", ROMX, BANK[3]

OverworldMap::
    db (2) * 2      ; Width
    db (2 * 2) * 2  ; Size

    db 3
    far_pointer pb16_OverworldTiles

    db DebugMetatileDefinitions.end - DebugMetatileDefinitions
    db BANK(DebugMetatileDefinitions)
    dw DebugMetatileDefinitions
    dw DebugMetatileAttributes
    dw DebugMetatileData

.map
    dw DebugMap, DebugMap2
    dw DebugMap2, DebugMap
.data
    dw DebugMap.data, DebugMap2.data
    dw DebugMap2.data, DebugMap.data

DebugMap: ; Using DebugMetatiles
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $01, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01
    db $01, $00, $01, $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $01, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $01
    db $01, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01
    db $04, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $05
    db $04, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $05
    db $01, $03, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
.data
    create_entity HitDummy, 256/2 + 256/4, 256/2
    set_warp 0, 2, 2, MAP_OVERWORLD, 0, 1, 256/2, 256/2
    end_mapdata

DebugMap2: ; Using DebugMetatiles
    db $00, $06, $06, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    db $01, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $01, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02
    db $04, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $05
    db $04, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $05
    db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
.data:
    end_mapdata