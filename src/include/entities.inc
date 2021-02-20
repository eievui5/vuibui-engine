include "structs.inc"

    IF !DEF(ENTITIES_INC)
ENTITIES_INC SET 1

    struct Entity
        bytes 2, Script 
        bytes 1, YPos
        bytes 1, XPos
        bytes 1, CollisionData
        bytes 1, Health
        ; bytes 1, Knockback_Y
        ; bytes 1, Knockback_X
        ; bytes 1, Velocity_Y
        ; bytes 1, Velocity_X
        ; bytes 1, Direction (replace flags)
        bytes 1, State ; Remove this?
        bytes 1, Flags ; This can replace State
        bytes 1, Timer
        end_struct

MAX_ENTITIES EQU 12

    ENDC