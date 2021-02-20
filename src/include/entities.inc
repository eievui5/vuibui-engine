include "structs.inc"

    IF !DEF(ENTITIES_INC)
ENTITIES_INC SET 1

    struct Entity
        ; Public - Engine relies on these values.
        bytes 2, Script         ; Run once per frame by the entity handler.
        bytes 1, YPos           ; Where is the entity. Used for collision.
        bytes 1, XPos           ; 
        bytes 1, YVel           ; How much should we be moving right now?
        bytes 1, XVel           ; 
        bytes 1, CollisionData  ; Upper nibble for flags, lower for damage.
        ; Private - Names are just suggestions
        bytes 1, Health         ; How many hits can I take?
        bytes 1, Direction      ; Often used to offset metasprites.
        bytes 1, State          ; Have I been knocked back? Killed? Am I attacking?
        bytes 1, Timer          ; Used for various delays and animations
        bytes 1, Priv1          ; Reserved Private Vars
        bytes 1, Priv2          ; 
        end_struct              ; 13 bytes long. Let's keep this under 16.

MAX_ENTITIES EQU 12

    ENDC