    IF !DEF(SAVE_INC)
DEF SAVE_INC EQU 1

INCLUDE "flags.inc"
INCLUDE "structs.inc"

DEF NB_SAVES EQU 1
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
        bytes 1, OctaviaDisabled
        bytes 1, PoppyDisabled
        bytes 1, TiberDisabled
        bytes 1, OctaviaMaxHealth
        bytes 1, PoppyMaxHealth
        bytes 1, TiberMaxHealth
        bytes 1, OctaviaUnlockedItems
        bytes 1, PoppyUnlockedItems
        bytes 1, TiberUnlockedItems
        bytes 1, OctaviaEquippedItems
        bytes 1, PoppyEquippedItems
        bytes 1, TiberEquippedItems
        bytes FLAG_SIZE, Bitfield
    end_struct

    ENDC
