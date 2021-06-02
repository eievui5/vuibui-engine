INCLUDE "include/banks.inc"
INCLUDE "include/directions.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/players.inc"
INCLUDE "include/scripting.inc"
INCLUDE "include/switch.inc"
INCLUDE "include/text.inc"

MACRO load_hl_scriptpointer
    ld a, [wActiveScriptPointer + 1]
    ld l, a
    ld a, [wActiveScriptPointer + 2]
    ld h, a
ENDM

MACRO load_scriptpointer_hl
    ld a, l
    ld [wActiveScriptPointer + 1], a
    ld a, h
    ld [wActiveScriptPointer + 2], a
ENDM

SECTION "Script Handlers", ROM0

HandleScript::
    ld a, [wActiveScriptPointer]
    swap_bank
.nextByte
    load_hl_scriptpointer
    ; [hl] -> Script Byte
    ld a, [hl]
    call HandleJumpTable
        ASSERT SCRIPT_END == 0
        dw ScriptEnd
        ASSERT SCRIPT_NULL == 1
        dw ScriptNull
        ASSERT SCRIPT_TEXT == 2
        dw ScriptText
        ASSERT SCRIPT_SETPOS_PLAYER == 3
        dw ScriptSetposPlayer
        ASSERT SCRIPT_BRANCH == 4
        dw ScriptBranch
        ASSERT SCRIPT_SET_POINTER == 5
        dw ScriptSetPointer
        ASSERT SCRIPT_FUNCTION == 6
        dw ScriptFunction
        ASSERT SCRIPT_COMPARE == 7
        dw ScriptCompare
        ASSERT SCRIPT_SET_TEXT_GRADIENT == 8
        dw ScriptSetTextGradient

; End of script!
ScriptEnd:
    ASSERT ENGINE_STATE_GAMEPLAY == 0
    xor a, a
    ldh [hEngineState], a
    ret

; Dummy script
ScriptNull:
    load_hl_scriptpointer
    inc hl
    load_scriptpointer_hl
    ret

ScriptText:
    load_hl_scriptpointer
    inc hl
    ; Load bank
    ld a, [hli]
    ld [wTextBank], a
    ; Load pointer
    ld a, [hli]
    ld [wTextPointer], a
    ld a, [hl]
    ld [wTextPointer + 1], a
    call HandleTextbox
    load_hl_scriptpointer
    inc hl 
    inc hl 
    inc hl
    inc hl
    load_scriptpointer_hl
    ret

ScriptSetposPlayer:
    load_hl_scriptpointer
    inc hl
    ld a, [hli] ; Load Player Offset
    add_r16_a de, wPlayerArray + Entity_YPos ; Offset to current player
    ld a, [hli]
    ld [de], a ; Copy YPos
    inc e ; this is safe
    ld a, [hli]
    ld [de], a ; XPos
    ld a, Entity_Direction - Entity_XPos
    add a, e
    ld e, a
    ld a, [hli] ; hl is now the next script instruction
    ld [de], a ; Direction
    ASSERT Entity_Frame - Entity_Direction == 1
    inc e
    ld [de], a ; A bit of a hack, but I wanna set direction *and* frame.
    load_scriptpointer_hl ; restore and exit
    ret

ScriptBranch:
    load_hl_scriptpointer
    inc hl
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [de]
    cp a, [hl]
    inc hl ; Luckily, this touches no flags!
    jr z, .skipOne
    inc hl
    inc hl
.skipOne
    ld a, [hli]
    ld [wActiveScriptPointer + 1], a
    ld a, [hl]
    ld [wActiveScriptPointer + 2], a
    ret

ScriptSetPointer:
    load_hl_scriptpointer
    inc hl
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld [de], a
    load_scriptpointer_hl ; restore and exit
    ret

ScriptFunction:
    load_hl_scriptpointer
    inc hl
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    load_scriptpointer_hl ; restore
    ld h, d
    ld l, e
    jp hl

ScriptCompare:
    load_hl_scriptpointer
    inc hl
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [de]
    ld b, a
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [de]
    cp a, b
    jr z, .skipOne
    inc hl
    inc hl
.skipOne
    ld a, [hli]
    ld [wActiveScriptPointer + 1], a
    ld a, [hl]
    ld [wActiveScriptPointer + 2], a
    ret

ScriptSetTextGradient:
    load_hl_scriptpointer
    inc hl
    ld a, [hli] ; Load text gradient bank
    ld [wTextboxPalsBank], a
    ld a, [hli]
    ld [wTextboxPalettes + 1], a
    ld a, [hli]
    ld [wTextboxPalettes], a
    load_scriptpointer_hl ; restore and exit
    ret

SECTION "Script Variables", WRAM0

wActiveScriptPointer::
    ds 3 ; bank, little endian pointer