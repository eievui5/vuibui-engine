INCLUDE "banks.inc"
INCLUDE "directions.inc"
INCLUDE "engine.inc"
INCLUDE "entity.inc"
INCLUDE "players.inc"
INCLUDE "scripting.inc"
INCLUDE "optimize.inc"
INCLUDE "text.inc"

MACRO load_hl_scriptpointer
    ld hl, wActiveScriptPointer + 1
    ld a, [hli]
    ld h, [hl]
    ld l, a
ENDM

MACRO load_scriptpointer_hl
    ld a, l
    ld [wActiveScriptPointer + 1], a
    ld a, h
    ld [wActiveScriptPointer + 2], a
ENDM

SECTION "Script Handlers", ROM0

HandleScript::
.nextByte
    ld hl, wActiveScriptPointer
    ld a, [hli]
    rst SwapBank
    ld a, [hli]
    ld h, [hl]
    ld l, a

    ; [hl] -> Script Byte
    ld a, [hl]
    ld hl, ScriptBytecodeJumpTable
    jp HandleJumpTable

ScriptBytecodeJumpTable:
    ASSERT SCRIPT_END == 0
    DW ScriptEnd
    ASSERT SCRIPT_NULL == 1
    DW ScriptNull
    ASSERT SCRIPT_TEXT == 2
    DW ScriptText
    ASSERT SCRIPT_SETPOS_PLAYER == 3
    DW ScriptSetposPlayer
    ASSERT SCRIPT_BRANCH == 4
    DW ScriptBranch
    ASSERT SCRIPT_SET_POINTER == 5
    DW ScriptSetPointer
    ASSERT SCRIPT_FUNCTION == 6
    DW ScriptFunction
    ASSERT SCRIPT_COMPARE == 7
    DW ScriptCompare
    ASSERT SCRIPT_SET_TEXT_GRADIENT == 8
    DW ScriptSetTextGradient
    ASSERT SCRIPT_PAUSE == 9
    DW ScriptPause
    ASSERT SCRIPT_UNPAUSE == 10
    DW ScriptUnpause
    ASSERT SCRIPT_FADE == 11
    DW ScriptFade
    ASSERT SCRIPT_WAIT_FADE == 12
    DW ScriptWaitFade
    ASSERT SCRIPT_JUMP == 13
    DW ScriptJump
    ASSERT SCRIPT_ADD_POINTER == 14
    DW ScriptAddPointer

; End of script!
ScriptEnd:
    ASSERT ENGINE_STATE_GAMEPLAY == 0
    xor a, a
    ldh [hPaused], a ; Unpause (if paused)
    ld hl, wActiveScriptPointer ; Clear script
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ret

; Dummy script
ScriptNull:
    load_hl_scriptpointer
    inc hl
    jp ScriptExitStub

ScriptText:
    load_hl_scriptpointer
    inc hl
    ; Load bank
    ld a, [hli]
    ld [wTextBank], a
    ; Load pointer
    ld a, [hli]
    ld [wTextPointer + 1], a
    ld a, [hl]
    ld [wTextPointer], a
    call HandleTextbox
    load_hl_scriptpointer
    inc hl
    inc hl
    inc hl
    inc hl
    jp ScriptExitStub

ScriptSetposPlayer:
    load_hl_scriptpointer
    inc hl
    ld a, [hli] ; Load Player Offset
    ; Offset to current player
    ; Add `a` to `wPlayerArray + Entity_YPos` and store in `de`
    add a, LOW(wPlayerArray + Entity_YPos)
    ld e, a
    adc a, HIGH(wPlayerArray + Entity_YPos)
    sub a, e
    ld d, a

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
    jp ScriptExitStub

ScriptBranch:
    load_hl_scriptpointer
    inc hl
    ; Load pointer
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [de]
    ; Compare pointer to value and jump if equal.
    cp a, [hl]
    inc hl ; Luckily, this touches no flags!
    jr nz, .fail
    ; Jump to pointer
    ld a, [hli]
    ld [wActiveScriptPointer + 1], a
    ld a, [hl]
    ld [wActiveScriptPointer + 2], a
    ret
.fail
    ; Skip pointer
    inc hl
    inc hl
    jp ScriptExitStub


ScriptSetPointer:
    load_hl_scriptpointer
    inc hl
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld [de], a
    jp ScriptExitStub

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
    ; Grab first pointer
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [de]
    ld b, a
    ; Grab second pointer
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [de]
    ; Return if the pointers are not equal
    cp a, b
    jr nz, .fail
    ; Otherwise, jump to the pointer
    ld a, [hli]
    ld [wActiveScriptPointer + 1], a
    ld a, [hl]
    ld [wActiveScriptPointer + 2], a
    ret
.fail
    ; Skip the pointer
    inc hl
    inc hl
    jr ScriptExitStub

ScriptSetTextGradient:
    load_hl_scriptpointer
    inc hl
    ld a, [hli] ; Load text gradient bank
    ld [wTextboxPalsBank], a
    ld a, [hli]
    ld [wTextboxPalettes + 1], a
    ld a, [hli]
    ld [wTextboxPalettes], a
    jr ScriptExitStub

ScriptPause:
    ld a, 1
    ldh [hPaused], a
    jp ScriptNull

ScriptUnpause:
    xor a, a
    ldh [hPaused], a
    jp ScriptNull

ScriptFade:
    load_hl_scriptpointer
    inc hl
    ld a, [hli]
    ld [wPaletteState], a
    jp ScriptExitStub

ScriptWaitFade:
	halt
	ld a, [wPaletteState]
	and a, a
	jr nz, ScriptWaitFade
    jp ScriptNull

; Move the script pointer to jump to another location.
ScriptJump:
    load_hl_scriptpointer
    inc hl
    ld a, [hli]
    ld [wActiveScriptPointer + 1], a
    ld a, [hl]
    ld [wActiveScriptPointer + 2], a
    ret

ScriptAddPointer:
    load_hl_scriptpointer
    inc hl
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [de]
    add a, [hl]
    ld [de], a
    inc hl
    fall ScriptExitStub

; Save some space with a tail call.
ScriptExitStub:
    load_scriptpointer_hl ; restore and exit
    ret

SECTION "Script Variables", WRAM0

wActiveScriptPointer::
    DS 3 ; bank, little endian pointer

; 16 general-purpose bytes intended for use by script commands.
wScriptVars::
    DS 16
