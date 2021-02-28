
INCLUDE "include/text.inc"
INCLUDE "include/engine.inc"

SECTION "Text Box", ROM0

; How many tiles can we set per frame?
TILESET_PER_FRAME EQU 10

; Initiallize, render, and close the textbox.
HandleTextbox::
    ld a, [wTextState]
    and a, a
    ret z ; No flag state? Return
    ASSERT TEXT_START == 1
    dec a
    jr z, .start
.start
    xor a, a
    ld [wTextScreenIndex], a
    ld a, ENGINE_TEXT
    ldh [hEngineState], a



SECTION "Dialogue", ROMX

DebugOh::
    db "Oh?@"

DebugHello::
    db "Hello.\n"
    db "How're you?@"

DebugGoodbye::
    db "See ya!\n"
    db " $ $ $ $\n"
    
    db "... why haven't\n"
    db "you left yet?@"

SECTION "Text Variables", WRAM0

; See text.inc TEXT_* constants. Set to TEXT_START to draw from wTextPointer
wTextState::
    ds 1

; Pointer to the next character.
wTextPointer::
    ds 2

; Where are we on the screen?
wTextScreenIndex::
    ds 1