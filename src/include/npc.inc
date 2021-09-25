
    IF !DEF(NPCS_INC)
DEF NPCS_INC EQU 1

INCLUDE "include/structs.inc"

DEF NB_NPCS EQU 4

    ; Used to define an NPC tile. NPCs are like entities, but cannot move. They only
    ; face towards the player and contain a script for when they're interacted with.
    struct NPC
        bytes 1, MetaspritesBank
        words 1, Metasprites ; 4 facing directions.
        bytes 1, Direction
        bytes 1, Position ; Upper nibble - Y, Lower Nibble - X
        bytes 1, ScriptBank
        words 1, Script
    end_struct

    ENDC