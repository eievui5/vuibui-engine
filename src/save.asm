INCLUDE "include/hardware.inc"
INCLUDE "include/save.inc"

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
    rst memcopy_small

    ; Initiallize save file
    ld a, BANK(xDefaultSaveFile)
    rst SwapBank
    ld hl, xDefaultSaveFile
    ld de, sSave0
    ld c, sizeof_Save
    rst memcopy_small

    ; Disable External Save RAM
    xor a, a
    ld [rRAMG], a
    ret

SECTION "Manage Save File", ROMX

; Updates the position data based on the current game state. This is used to
; create respawn locations.
xUpdateRepawnPoint::
    ld hl, wRepawnPoint
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
    ld hl, wRepawnPoint
    ASSERT Save_WorldMapID == 0
    ld a, [hli]
    ld [wActiveWorldMap], a
    ASSERT Save_WorldMapX == 1
    ld a, [hli]
    ld [wWorldMapPositionX], a
    ASSERT Save_WorldMapY == 2
    ld a, [hli]
    ld [wWorldMapPositionY], a
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
    ld de, wRepawnPoint
    ld c, sizeof_RespawnPoint
    rst memcopy_small

    ; Disable External Save RAM
    xor a, a
    ld [rRAMG], a
    ret

SECTION "Save Verification", ROMX

; Used to verify that the save file is not corrupted or uninitiallized.
xSaveCheckString:
    db "This is a VuiBui engine save file. Do not edit this corruption test string. All save data will be overwritten if it does not match.\n"
.end

SECTION "Template Saves", ROMX

    dstruct Save, xDefaultSaveFile, \
    0,        \ ; World Map
    0, 0,     \ ; World Map Position
    128, 128, \ ; Octavia Position
    112, 128, \ ; Poppy Position
    144, 128    ; Tiber Position

ASSERT @ - xDefaultSaveFile == sizeof_Save, "Incorrect save file size!"

SECTION "Save Position Data", WRAM0

; The position of the players. Used for respawning and is merged into the save
; file when the players save the game.
    dstruct RespawnPoint, wRepawnPoint

SECTION "Save Data", SRAM

; Used to verify that the save file is not corrupted or uninitiallized.
sCheckString:
    ds xSaveCheckString.end - xSaveCheckString

SECTION "Save Files", SRAM

sSaveFiles:
    dstructs NB_SAVES, Save, sSave