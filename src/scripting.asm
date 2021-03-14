
INCLUDE "include/defines.inc"
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

    ; Change bank here

    load_hl_scriptpointer
    ; [hl] -> Script Byte
    ld a, [hl]
    switch
    case SCRIPT_END, ScriptEnd
    case SCRIPT_NULL, ScriptNull
    case SCRIPT_TEXT, ScriptText
    case SCRIPT_SETPOS_PLAYER, ScriptSetposPlayer
    end_switch

; End of script!
ScriptEnd:
    ASSERT ENGINE_NORMAL == 0
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
    ld a, [wTextScriptFinished]
    and a, a
    jr nz, .textEnd
    ld a, [wTextState]
    ASSERT TEXT_HIDDEN == 0
    and a, a
    ret nz
.textStart
    ld a, TEXT_START
    ld [wTextState], a
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
    ret
.textEnd
    ; Clear finished flag
    xor a, a
    ld [wTextScriptFinished], a
    load_hl_scriptpointer
    ld a, 4
    add_r16_a h, l
    load_scriptpointer_hl
    ret

ScriptSetposPlayer:
    load_hl_scriptpointer
    inc hl
    ld de, wPlayerArray + Entity_YPos
    ld a, [hli] ; Load Player Offset
    add_r16_a d, e ; Offset to current player
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


SECTION "Script", ROMX

DebugScript::
    display_text DebugOh
    setpos_player PLAYER_OCTAVIA, 20, 20, DIR_OFFSET_RIGHT
    display_text DebugHello
    setpos_player PLAYER_OCTAVIA, 80, 80, DIR_OFFSET_UP
    display_text DebugGoodbye
    setpos_player PLAYER_OCTAVIA, 0, 0, DIR_OFFSET_DOWN
    end_script

SECTION "Script Variables", WRAM0

wActiveScriptPointer::
    ds 3 ; bank, little endian pointer

; Is the text we created done?
wTextScriptFinished::
    ds 1