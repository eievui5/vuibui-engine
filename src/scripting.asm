INCLUDE "include/banks.inc"
INCLUDE "include/directions.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/entity.inc"
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
.nextByte
    ld hl, wActiveScriptPointer
    ld a, [hli]
    rst SwapBank
    ld a, [hli]
    ld h, [hl]
    ld l, a

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
        ASSERT SCRIPT_PAUSE == 9
        dw ScriptPause
        ASSERT SCRIPT_UNPAUSE == 10
        dw ScriptUnpause
        ASSERT SCRIPT_FADE == 11
        dw ScriptFade
        ASSERT SCRIPT_WAIT_FADE == 12
        dw ScriptWaitFade
        ASSERT SCRIPT_JUMP == 13
        dw ScriptJump
        ASSERT SCRIPT_ADD_POINTER == 14
        dw ScriptAddPointer

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
    ld [wPaletteThread], a
    jp ScriptExitStub

ScriptWaitFade:
	halt
	ld a, [wPaletteThread]
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
    jp ScriptExitStub

; Save some space with a tail call.
ScriptExitStub:
    load_scriptpointer_hl ; restore and exit
    ret

SECTION "Script Variables", WRAM0

wActiveScriptPointer::
    ds 3 ; bank, little endian pointer

; 16 general-purpose bytes intended for use by script commands.
wScriptVars::
    ds 16