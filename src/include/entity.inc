
    IF !DEF(ENTITIES_INC)
DEF ENTITIES_INC EQU 1

INCLUDE "enum.inc"
INCLUDE "structs.inc"

    struct Entity
        words 1, DataPointer   ; Used to look up constant information
        bytes 1, YPos          ; Where is the entity. Used for collision.
        bytes 1, XPos          ;
        bytes 1, YVel          ; How much should we be moving right now?
        bytes 1, XVel          ; Also used for knockback, since entities overwrite their velocities.
        bytes 1, CollisionData ; Upper nibble for flags, lower for damage.
        bytes 1, Health        ; How many hits can I take?
        bytes 1, Direction     ;
        bytes 1, Frame         ; What frame are we on? Used by the entity renderer.
        bytes 1, Flags         ;
        bytes 1, State         ; Have I been knocked back? Killed? Am I attacking? $00 = initiallize.
        bytes 1, Timer         ; Used for various delays and animations
        bytes 1, InvTimer      ; Second timer for invicibility. If bit 2 is set the pallet swaps.
        bytes 1, YFrac         ; For 8.8 fixed-point, if needed.
        bytes 1, XFrac         ;
    end_struct                 ; 16 bytes long. You may not go over or under 16.
    ASSERT sizeof_Entity == 16

    struct EntityDefinition
        dunion   Logic
        bytes 1, LogicBank
        words 1, LogicPointer

        dunion   Metasprites
        bytes 1, MetaspritesBank
        words 1, MetaspritesPointer

        dunion   Render
        bytes 1, RenderBank
        words 1, RenderPointer
    end_struct

    DEF DAMAGE_MASK EQU $0F
    start_enum DAMAGE_EFFECT, 16, 16 ; Start on the upper nibble
        enum FIRE
        enum ICE
        enum SHOCK
    end_enum

DEF ENTITY_DETECTION_SIZE EQU 8 ; (8 * 8) = 16 / (16 - 2)

DEF BOUNDING_BOX_X EQU 6 ; A bit smaller than 16*16, because that feel/looks better.
DEF BOUNDING_BOX_Y EQU 6

DEF NB_ENTITIES EQU 8 ; Max entities cannot go higher than 16.
ASSERT NB_ENTITIES <= 16

MACRO def_entity ; logic, metasprites, rendering
    ASSERT _NARG == 3, "Expected 3 arguments."
    DB BANK(\1)
    DW \1
    DB BANK(\2)
    DW \2
    DB BANK(\3)
    DW \3
    ASSERT sizeof_EntityDefinition == 9
ENDM

    ENDC
