INCLUDE "include/structs.inc"

    ; Defines a sprite as it is in OAM
    struct Sprite
    bytes 1, YPos
    bytes 1, XPos
    bytes 1, Tile
    bytes 1, Attr
    end_struct