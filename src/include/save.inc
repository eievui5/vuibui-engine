
    IF !DEF(SAVE_INC)
DEF SAVE_INC EQU 1

INCLUDE "include/structs.inc"

DEF SAVE_VERSION EQU 0

    struct RespawnPoint
        bytes 1, WorldMapID
        bytes 1, WorldMapX
        bytes 1, WorldMapY
        bytes 1, OctaviaPosX
        bytes 1, OctaviaPosY
        bytes 1, PoppyPosX
        bytes 1, PoppyPosY
        bytes 1, TiberPosX
        bytes 1, TiberPosY
    end_struct

    struct Save
        extends RespawnPoint
    end_struct

DEF NB_SAVES EQU 1

    ENDC