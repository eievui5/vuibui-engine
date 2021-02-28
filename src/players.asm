
INCLUDE "include/entities.inc"

SECTION "Player Variables", WRAM0

; The Character currently being controlled by the player. Used as an offset.
ActivePlayer::
    ; 0: Octavia
    ds 1

PlayerArray::
    dstruct Entity, Octavia
