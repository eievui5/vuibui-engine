include "structs.inc"

    struct Entity
        ; Engine-sensitive
        bytes 2, Script 
        bytes 1, YPos
        bytes 1, XPos
        bytes 1, CollisionData
        ; Arbitrary :) - Use however you like.
        bytes 1, Health 
        bytes 1, State 
        bytes 1, Flags
        bytes 1, Timer
        end_struct

MAX_ENTITIES EQU 20