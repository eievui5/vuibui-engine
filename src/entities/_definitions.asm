
INCLUDE "include/macros.inc"
INCLUDE "include/entities.inc"

SECTION "Entity Definitions", ROMX

/*

EntityName::
    far_pointer EntityScript ; Run once per frame when hEngineState == 0
    far_pointer EntityMetaspriteLookup ; must be same bank as script

*/

; I may want to update this from a Metasprite lookup to a rendering script at some point.
; Seperating logic and animations would be nice, plus it would mean that Entity_Facing actually determines what frame we're on.
; Not entirely sure if I'll *ever* need this, so I've not implemented it yet.

PlayerOctavia::
    far_pointer OctaviaPlayerLogic
    far_pointer OctaviaMetasprites

PlayerSpell::
    far_pointer ProjectileLogic
    far_pointer OctaviaSpellMetasprites

HitDummy::
    far_pointer HitDummyScript
    far_pointer OctaviaMetasprites
    