
INCLUDE "include/macros.inc"
INCLUDE "include/entities.inc"

SECTION "Entity Definitions", ROMX

/*

EntityName::
    far_pointer EntityScript ; Run once per frame when hEngineState == 0
    far_pointer EntityMetaspriteLookup ; must be same bank as script

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
    