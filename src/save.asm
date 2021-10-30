INCLUDE "hardware.inc"
INCLUDE "lb.inc"
INCLUDE "map.inc"
INCLUDE "players.inc"
INCLUDE "save.inc"

SECTION "Save Functions", ROM0

; Makes sure the save files is valid, initiallizes SRAM if not.
VerifySRAM::
    ; Enable External Save RAM
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a

    ld a, BANK(xSaveCheckString)
    rst SwapBank
    ld hl, sCheckString
    ld de, xSaveCheckString
    ld b, xSaveCheckString.end - xSaveCheckString
.loop
    ld a, [de]
    cp a, [hl]
    jr nz, .fail
    inc hl
    inc de
    dec b
    jr nz, .loop
    ret

.fail

    ; Re-write the string
    ld hl, xSaveCheckString
    ld de, sCheckString
    ld c, xSaveCheckString.end - xSaveCheckString
    rst MemCopySmall

    ; Initiallize save file
    ld hl, xDefaultSaveFile
    ld de, sSave0
    lb bc, BANK(xDefaultSaveFile), sizeof_Save
    call MemCopyFar

    ; Disable External Save RAM
    xor a, a
    ld [rRAMG], a
    ret

SECTION "Manage Save File", ROMX

; Updates the position data based on the current game state. This is used to
; create respawn locations.
xUpdateRepawnPoint::
    ld hl, wRespawnPoint
    ASSERT Save_WorldMapID == 0
    ld a, [wActiveWorldMap]
    ld [hli], a
    ASSERT Save_WorldMapX == 1
    ld a, [wWorldMapPositionX]
    ld [hli], a
    ASSERT Save_WorldMapY == 2
    ld a, [wWorldMapPositionY]
    ld [hli], a
    ASSERT Save_OctaviaPosX == 3
    ld a, [wOctavia_XPos]
    ld [hli], a
    ASSERT Save_OctaviaPosY == 4
    ld a, [wOctavia_YPos]
    ld [hli], a
    ASSERT Save_PoppyPosX == 5
    ld a, [wPoppy_XPos]
    ld [hli], a
    ASSERT Save_PoppyPosY == 6
    ld a, [wPoppy_YPos]
    ld [hli], a
    ASSERT Save_TiberPosX == 7
    ld a, [wTiber_XPos]
    ld [hli], a
    ASSERT Save_TiberPosY == 8
    ld a, [wTiber_YPos]
    ld [hli], a
    ret

; Update the map and player positions to match the last saved respawn point.
xLoadRepawnPoint::
    ld hl, wRespawnPoint
    ASSERT Save_WorldMapID == 0
    ld a, [hli]
    ld [wActiveWorldMap], a
    ASSERT Save_WorldMapX == 1
    ld a, [hli]
    ld [wWorldMapPositionX], a
    ld [wPlayerRoom.octavia + 1], a
    ld [wPlayerRoom.poppy + 1], a
    ld [wPlayerRoom.tiber + 1], a
    ASSERT Save_WorldMapY == 2
    ld a, [hli]
    ld [wWorldMapPositionY], a
    ld [wPlayerRoom.octavia], a
    ld [wPlayerRoom.poppy], a
    ld [wPlayerRoom.tiber], a
    ASSERT Save_OctaviaPosX == 3
    ld a, [hli]
    ld [wOctavia_XPos], a
    ASSERT Save_OctaviaPosY == 4
    ld a, [hli]
    ld [wOctavia_YPos], a
    ASSERT Save_PoppyPosX == 5
    ld a, [hli]
    ld [wPoppy_XPos], a
    ASSERT Save_PoppyPosY == 6
    ld a, [hli]
    ld [wPoppy_YPos], a
    ASSERT Save_TiberPosX == 7
    ld a, [hli]
    ld [wTiber_XPos], a
    ASSERT Save_TiberPosY == 8
    ld a, [hli]
    ld [wTiber_YPos], a
    ret

; Loads a save file to initialize the game.
; @ hl:  Pointer to save file
xLoadSaveFile::
    ; Enable External Save RAM
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a

    ; Copy the respawn position from the save file.
    ld de, wRespawnPoint
    ld c, sizeof_RespawnPoint
    rst MemCopySmall

    ; Load Max health values
    ASSERT sizeof_RespawnPoint == Save_OctaviaMaxHealth
    ld a, [hli]
    ld [wOctavia_Health], a
    ld [wPlayerMaxHealth.octavia], a
    ld a, [hli]
    ld [wPoppy_Health], a
    ld [wPlayerMaxHealth.poppy], a
    ld a, [hli]
    ld [wTiber_Health], a
    ld [wPlayerMaxHealth.tiber], a

    ASSERT Save_OctaviaMaxHealth + 3 == Save_OctaviaUnlockedItems
    ld a, [hli]
    ld [wItems.octavia], a
    ld a, [hli]
    ld [wItems.poppy], a
    ld a, [hli]
    ld [wItems.tiber], a

    ASSERT Save_OctaviaUnlockedItems + 3 == Save_OctaviaEquippedItems
    ld a, [hli]
    ld [wPlayerEquipped.octavia], a
    ld a, [hli]
    ld [wPlayerEquipped.poppy], a
    ld a, [hli]
    ld [wPlayerEquipped.tiber], a

    ; Assert that this function is up-to-date with the save file.
    ASSERT Save_OctaviaEquippedItems + 3 == sizeof_Save

    ; Disable External Save RAM
    xor a, a
    ld [rRAMG], a
    ret

; Store a save file to SRAM.
; @ de:  Pointer to save file
xStoreSaveFile::
    ; Enable External Save RAM
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a

    ; Copy the respawn position to the save file.
    ld hl, wRespawnPoint
    ld c, sizeof_RespawnPoint
    rst MemCopySmall

    ; Load Max health values
    ASSERT sizeof_RespawnPoint == Save_OctaviaMaxHealth
    ld a, [wPlayerMaxHealth.octavia]
    ld [de], a
    inc de
    ld a, [wPlayerMaxHealth.poppy]
    ld [de], a
    inc de
    ld a, [wPlayerMaxHealth.tiber]
    ld [de], a
    inc de

    ASSERT Save_OctaviaMaxHealth + 3 == Save_OctaviaUnlockedItems
    ld a, [wItems.octavia]
    ld [de], a
    inc de
    ld a, [wItems.poppy]
    ld [de], a
    inc de
    ld a, [wItems.tiber]
    ld [de], a
    inc de

    ASSERT Save_OctaviaUnlockedItems + 3 == Save_OctaviaEquippedItems
    ld a, [wPlayerEquipped.octavia]
    ld [de], a
    inc de
    ld a, [wPlayerEquipped.poppy]
    ld [de], a
    inc de
    ld a, [wPlayerEquipped.tiber]
    ld [de], a
    inc de

    ; Assert that this function is up-to-date with the save file.
    ASSERT Save_OctaviaEquippedItems + 3 == sizeof_Save

    ; Disable External Save RAM
    xor a, a
    ld [rRAMG], a
    ret

SECTION "Save Verification", ROMX

; Used to verify that the save file is not corrupted or uninitiallized.
xSaveCheckString:
    DB "This is a VuiBui engine save file. Do not edit this corruption test string. All save data will be overwritten if it does not match.\n"
.end

SECTION "Template Saves", ROMX

    dstruct Save, xDefaultSaveFile, \
    MAP_OVERWORLD, \ ; World Map.
    0, 0,       \ ; World Map Position.
    128, 128,   \ ; Octavia Position.
    112, 128,   \ ; Poppy Position.
    144, 128,   \ ; Tiber Position.
    10, 10, 10, \ ; Max healths.
    ITEMF_FIRE_WAND | ITEMF_HEAL_WAND, \ ; Octavia items.
    ITEMF_BOW, \ ; Poppy items.
    ITEMF_SWORD, \ ; Tiber items.
    ITEMF_FIRE_WAND, \ ; Octavia equipped.
    ITEMF_BOW, \ ; Poppy equipped.
    ITEMF_SWORD \ ; Tiber equipped.

ASSERT @ - xDefaultSaveFile == sizeof_Save, "Incorrect save file size!"

SECTION "Save Position Data", WRAM0

; The position of the players. Used for respawning and is merged into the save
; file when the players save the game.
    dstruct RespawnPoint, wRespawnPoint

SECTION "Save Data", SRAM

; Used to verify that the save file is not corrupted or uninitiallized.
sCheckString:
    DS xSaveCheckString.end - xSaveCheckString

SECTION "Save Files", SRAM

sSaveFiles:
    dstructs NB_SAVES, Save, sSave