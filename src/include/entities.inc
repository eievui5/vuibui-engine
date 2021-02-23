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
        ; Private - Names are just suggestions. The engine may set these, but they can be ignored.
        bytes 1, Health         ; How many hits can I take?
        bytes 1, Flags          ; Flags can be set by the spawning script to slightly vary enemies
        bytes 1, Direction      ; Often used to offset metasprites.
        bytes 1, State          ; Have I been knocked back? Killed? Am I attacking? $00 = initiallize.
        bytes 1, Timer          ; Used for various delays and animations
        ; Reserved Private Vars - No suggested use, but required for padding size up to 16
        bytes 1, Priv1          ; 
        bytes 1, Priv2          ; 
        bytes 1, Priv3          ; 
        bytes 1, Priv4          ; 
        end_struct              ; 16 bytes long. You may not go over 16, because entities use StructSeekUnsafe for speed.

MAX_ENTITIES EQU 20

    ENDC