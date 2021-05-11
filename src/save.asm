
SECTION "Save Functions", ROM0

VerifySRAM::
    ld hl, sTestString
    ld de, SaveTestString
    ld b, SaveTestString.end - SaveTestString
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
    ld hl, SaveTestString
    ld de, sTestString
    ld c, SaveTestString.end - SaveTestString
    rst memcopy_small

    ; Initiallize save file

    ret

SECTION "Save Verification", ROMX

; Used to verify that the save file is not corrupted or uninitiallized.
SaveTestString:
    db "VuiBuiEngineSave"
.end

SECTION "Template Saves", ROMX

DefaultSaveFile:
    db 0

SECTION "Save Data", SRAM

; Used to verify that the save file is not corrupted or uninitiallized.
sTestString:
    ds SaveTestString.end - SaveTestString

SECTION "Save Files", SRAM

sSaveFile:
    ds 1