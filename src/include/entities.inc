include "structs.inc"
include "macros.inc"

    IF !DEF(ENTITIES_INC)
ENTITIES_INC SET 1

; Used to find an entity's data at a given offset, storing it in hl. 
; @ bc: Entity Index
; @ 3 bytes
; @ 5 cycles
FindEntity: MACRO 
    ld hl, wEntityArray + \1
    add hl, bc
ENDM

 
; Clears an entity
; @ bc: Entity Index. Will be lost, but shouldn't matter.
kill_entity: MACRO 
    ld hl, wEntityArray
    add hl, bc
    xor a
    ld bc, sizeof_Entity
    call memset
ENDM

    struct Entity
        ; Public - Engine relies on these values.
        bytes 2, DataPointer    ; Used to look up constant information
        bytes 1, YPos           ; Where is the entity. Used for collision.
        bytes 1, XPos           ; 
        bytes 1, YVel           ; How much should we be moving right now?
        bytes 1, XVel           ; Also used for knockback, since entities overwrite their velocities.
        bytes 1, CollisionData  ; Upper nibble for flags, lower for damage.
        ; Private - 
        bytes 1, Health         ; How many hits can I take?
        bytes 1, Direction      ; 
        bytes 1, Frame          ; What frame are we on? Used by the entity renderer.
        bytes 1, Flags          ; 
        bytes 1, State          ; Have I been knocked back? Killed? Am I attacking? $00 = initiallize.
        bytes 1, Timer          ; Used for various delays and animations
        bytes 1, InvTimer       ; Second timer for invicibility. If bit 2 is set the pallet swaps.
        ; Reserved Private Vars - No suggested use, but required for padding size up to 16
        bytes 1, Priv1          ; 
        bytes 1, Priv2          ; 
    end_struct              ; 16 bytes long. You may not go over or under 16, because entities use StructSeekUnsafe for speed.

ASSERT sizeof_Entity == 16

ENTITY_DETECTION_SIZE EQU 7 ; (7 * 7) = 14 / (16 - 2)
MAX_ENTITIES EQU 20
MAX_PROJECTILES EQU 8

ENTITY_DEBUG_PLAYER EQU 1

    ENDC
