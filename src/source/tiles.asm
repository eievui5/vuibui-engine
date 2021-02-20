
include "include/tiles.inc"

SECTION "Tiles", ROMX 
DebugTiles::
    ; $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    ; $01
    db $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF
    ; $02
    db $FF, $FF, $FF, $FF
    db $00, $00, $00, $00
    db $FF, $FF, $FF, $FF
    db $00, $00, $00, $00
    ; $03
    db $FF, $00, $00, $FF
    db $FF, $00, $00, $FF
    db $FF, $00, $00, $FF
    db $FF, $00, $00, $FF
.end::

SECTION "Metatiles", ROMX 
DebugMetatileDefinitions:: ; Only 16 per set... is that bad?
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

SECTION "Level Maps", ROMX 
DebugTilemap:: ; Using DebugMetatiles
    db $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00
    db $00, $01, $01, $02, $00, $02, $00, $02
    db $02, $01, $01, $00, $02, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $00, $00, $02, $00
    db $00, $02, $00, $02, $00, $02, $00, $02
    db $02, $00, $02, $00, $02, $00, $02, $00
.end::
