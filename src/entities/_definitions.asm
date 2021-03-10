
INCLUDE "include/macros.inc"
INCLUDE "include/entities.inc"

SECTION "Entity Definitions", ROMX

/*

EntityName::
    far_pointer EntityScript
    far_pointer EntityMetaspriteLookup ; must be same bank as script

    ; Custom constants here (Want an entity that shares code with one difference?)
    ; Example:
    ; db $01 ; Normal Speed
    db $02 ; Fast version

*/

PlayerOctavia::
    far_pointer OctaviaPlayerLogic
    far_pointer OctaviaMetasprites

DebugPlayer::
    far_pointer DebugPlayerScript
    far_pointer OctaviaMetasprites

HitDummy::
    far_pointer HitDummyScript
    far_pointer OctaviaMetasprites
    