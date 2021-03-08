
INCLUDE "include/engine.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/scripting.inc"
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
    call HandleJumpTable
    ASSERT SCRIPT_END == 0
    dw Script.end
    ASSERT SCRIPT_NULL == 1
    dw Script.null
    ASSERT SCRIPT_TEXT == 2
    dw Script.text

Script:
; End of script!
.end
    ASSERT ENGINE_NORMAL == 0
    xor a, a
    ldh [hEngineState], a
    ret
; Dummy script
.null
    load_hl_scriptpointer
    inc hl
    load_scriptpointer_hl
    ret
.text
    ld a, [wTextScriptFinished]
    and a, a
    jr nz, .textEnd
    ld a, [wTextState]
    ASSERT TEXT_HIDDEN == 0
    and a, a
    ret nz
.textStart
    ld b, b
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


SECTION "Script", ROMX

DebugScript::
    display_text DebugOh
    display_text DebugHello
    display_text DebugGoodbye
    end_script

SECTION "Script Variables", WRAM0

wActiveScriptPointer::
    ds 3 ; bank, little endian pointer

; Is the text we created done?
wTextScriptFinished::
    ds 1