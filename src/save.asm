INCLUDE "hardware.inc"
INCLUDE "map.inc"
INCLUDE "players.inc"
INCLUDE "save.inc"
INCLUDE "optimize.inc"
INCLUDE "res/maps/beach/beach.inc"

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

    ; Disable External Save RAM
    xor a, a
    ld [rRAMG], a
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
; @ de:  Pointer to save file
xLoadSaveFile::
    ; Enable External Save RAM
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    ld hl, xSaveCopyList
.copy
    ; Grab length
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a
    ; And WRAM pointer (dest)
    ld a, [hli]
    push hl
    ld h, [hl]
    ld l, a

    dec bc
    inc b
    inc c
.loop:
    ld a, [de]
    ld [hli], a
    inc de
    dec c
    jr nz, .loop
    dec b
    jr nz, .loop

    pop hl
    inc hl
    ld a, [hli]
    or a, [hl]
    jr z, .exit
    dec hl
    jr .copy

.exit
    ; Disable External Save RAM
    xor a, a
    ld [rRAMG], a

    ; Initialize other variables upon load
    ld a, [wPlayerMaxHealth.octavia]
    ld [wOctavia_Health], a
    ld a, [wPlayerMaxHealth.poppy]
    ld [wPoppy_Health], a
    ld a, [wPlayerMaxHealth.tiber]
    ld [wTiber_Health], a
    ret

; Store a save file to SRAM.
; @ de:  Pointer to save file
xStoreSaveFile::
    ; Enable External Save RAM
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    ld hl, xSaveCopyList
.copy
    ; Grab length
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a
    ; And WRAM pointer (source)
    ld a, [hli]
    push hl
    ld h, [hl]
    ld l, a
    call MemCopy
    pop hl
    inc hl
    ld a, [hli]
    or a, [hl]
    jr z, .exit
    dec hl
    jr .copy

.exit
    ; Disable External Save RAM.
    xor a, a
    ld [rRAMG], a
    ret

xSaveCopyList:
    dw sizeof_RespawnPoint, wRespawnPoint
    dw 3, wPlayerDisabled
    dw 3, wPlayerMaxHealth
    dw 3, wItems
    dw 3, wPlayerEquipped
    dw FLAG_SIZE, wBitfield
    dw null

SECTION "Save Verification", ROMX
; Used to verify that the save file is not corrupted or uninitiallized.
xSaveCheckString:
    DB "This is a VuiBui engine save file. Do not edit this corruption test string. All save data will be overwritten if it does not match.\n"
.end

SECTION "Template Saves", ROMX
xDefaultSaveFile:
    db MAP_BEACH ; World Map.
    db Beach1_X, Beach1_Y ; World Map Position.

    db 128, 128 ; Octavia Position.
    db 0, 0     ; Poppy Position.
    db 0, 0     ; Tiber Position.

    db 0, 1, 1 ; Disable Poppy and Tiber.
    db 10, 10, 10 ; Max healths.

    ; Player items
    db 0, 0, 0
    ; Player equipped
    db 0, 0, 0

    ds FLAG_SIZE, 0 ; Zero-init all flags.

ASSERT @ - xDefaultSaveFile == sizeof_Save, "Incorrect save file size!"

xDebugSaveFile:
    db MAP_OVERWORLD ; World Map.
    db 0, 0          ; World Map Position.

    db 0, 0, 0
    db 128, 128   ; Octavia Position.
    db 112, 128   ; Poppy Position.
    db 144, 128   ; Tiber Position.

    db 10, 10, 10 ; Max healths.

    db ITEMF_FIRE_WAND | ITEMF_HEAL_WAND | ITEMF_ICE_WAND ; Octavia items.
    db ITEMF_BOW                                          ; Poppy items.
    db ITEMF_SWORD | ITEMF_SHIELD                         ; Tiber items.

    db ITEMF_FIRE_WAND ; Octavia equipped.
    db ITEMF_BOW       ; Poppy equipped.
    db ITEMF_SWORD     ; Tiber equipped.

    ds FLAG_SIZE, 0 ; Zero-init all flags.

ASSERT @ - xDebugSaveFile == sizeof_Save, "Incorrect save file size!"

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
