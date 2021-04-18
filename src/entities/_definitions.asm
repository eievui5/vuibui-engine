INCLUDE "include/banks.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/entities.inc"

SECTION "Entity Definitions", ROM0

/*

EntityName::
    far_pointer EntityScript ; Run once per frame when hEngineState == 0
    far_pointer EntityMetaspriteLookup ; must be same bank as script

*/

; I may want to update this from a Metasprite lookup to a rendering script at some point.
; Seperating logic and animations would be nice, plus it would mean that Entity_Facing actually determines what frame we're on.
; Not entirely sure if I'll *ever* need this, so I've not implemented it yet.

; This ensures that the low byte will never fall on $00, since entity array
; seekers treat LOW(Address) == 0 as "no entity".
DefStart:
PlayerOctavia::
    far_pointer OctaviaPlayerLogic
    far_pointer OctaviaMetasprites

PlayerPoppy::
    far_pointer PoppyPlayerLogic
    far_pointer PoppyMetasprites

PlayerTiber::
    far_pointer TiberPlayerLogic
    far_pointer TiberMetasprites

OctaviaSpell::
    far_pointer OctaviaSpellLogic
    far_pointer OctaviaSpellMetasprites

PoppyArrow::
    far_pointer PoppyArrowLogic
    far_pointer ArrowMetasprites

HitDummy::
    far_pointer HitDummyScript
    far_pointer OctaviaMetasprites


    
DefEnd: 

; Ensure that neither entity data pointer byte will equal $00.
FOR i, 0, (DefEnd-DefStart), 6
    ASSERT HIGH(DefStart + i) != $00
    ASSERT LOW(DefStart + i) != $00
ENDR