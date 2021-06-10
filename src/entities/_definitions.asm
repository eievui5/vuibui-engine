INCLUDE "include/banks.inc"
INCLUDE "include/entity.inc"

/* Entity Class format
EntityName::
    far_pointer EntityScript
        ; Run once per frame when hEngineState == 0

    far_pointer EntityMetaspriteLookup

    far_pointer EntityRenderingLogic 
        ; Must be in ROM0 or the same bank as EntityMetaspriteLookup

    ; Any extra constant data can go at the end :)
*/

SECTION "Entity Definitions", ROM0

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
    far_pointer RenderMetasprite.native
