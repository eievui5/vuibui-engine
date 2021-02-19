include "include/defines.inc"
include "include/hardware.inc"
include "include/tiles.inc"

SECTION "Tiles", ROMX 
DebugTiles::
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00

    db $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF

    db $FF, $FF, $FF, $FF
    db $00, $00, $00, $00
    db $FF, $FF, $FF, $FF
    db $00, $00, $00, $00

    db $FF, $00, $00, $FF
    db $FF, $00, $00, $FF
    db $FF, $00, $00, $FF
    db $FF, $00, $00, $FF
.end::

SECTION "Metatiles", ROMX 
DebugMetatileDefinitions::
    ; $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    ; $01
    db $01, $01, $01, $01
    db $01, $01, $01, $01
    db $01, $01, $01, $01
    db $01, $01, $01, $01
    ; $02
    db $03, $03, $03, $03
    db $03, $03, $03, $03
    db $03, $03, $03, $03
    db $03, $03, $03, $03
.end::

DebugMetatileData::
    ; $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    ; $01
    db TILE_COLLISION, TILE_COLLISION, TILE_COLLISION, TILE_COLLISION
    db TILE_COLLISION, TILE_COLLISION, TILE_COLLISION, TILE_COLLISION
    db TILE_COLLISION, TILE_COLLISION, TILE_COLLISION, TILE_COLLISION
    db TILE_COLLISION, TILE_COLLISION, TILE_COLLISION, TILE_COLLISION
    ; $02
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
.end::

SECTION "Tilemap", ROMX 
DebugTilemap:: ; DebugMetatiles
    db $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00
    db $00, $01, $01, $02, $00, $02, $00, $02
    db $02, $01, $01, $00, $02, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $00, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00
.end::