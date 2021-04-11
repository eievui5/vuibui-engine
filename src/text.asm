INCLUDE "include/banks.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/switch.inc"
INCLUDE "include/text.inc"

/* text.asm

    Functions related to the handling of the on-screen textbox, including
    dialogue choices.

    HandleTextbox
        - Initiallize, render, and close the textbox. Run once per frame from
        VBlank

*/

SECTION "Text Box", ROM0

; How many tiles can we set per frame?
TEXTBOX_WIDTH EQU 20

; Initiallize, render, and close the textbox.
; Sorry to anyone reading through this, it's not well-commented.
HandleTextbox::

    ld a, [wTextState]
    and a, a
    ret z ; No flag state? Return
    dec a ; Set the minimum value to 0 for switch
    switch
        case TEXT_START - 1, .start
        case TEXT_CLEARING - 1, .clearWindow
        case TEXT_CLEANING - 1, .cleanTiles
        case TEXT_DRAWING - 1, .drawing
        case TEXT_WAITING -1, .waiting
        case TEXT_ASK - 1, .ask
    end_switch

.start
    ; Reset Textbox screen index.
    xor a, a
    ld [wTextScreenIndex], a
    ; Hide Window
    ld a, 143
    ldh [rWY], a
    ldh [rLYC], a
    ; Update wTextState
    ld a, TEXT_CLEARING
    ld [wTextState], a
    ret

.clearWindow
    ; Map the window to textbox.
    ld d, high(_SCRN1)
    ld a, [wTextScreenIndex]
    swap a ; a * 16
    add a, a ; a * 32
    ld e, a ; Destination
    ld a, [wTextScreenIndex]
    ld c, a
    ld hl, TextboxMap
    swap a   ; a * 16
    add a, c ; a * 17
    add a, c ; a * 18
    add a, c ; a * 19
    add a, c ; a * 20
    add_r16_a h, l
    ld c, TEXTBOX_WIDTH
    rst memcopy_small

    ld a, [wTextScreenIndex]
    inc a
    ld [wTextScreenIndex], a
    cp a, 5 ; Copy 5 lines.
    ret nz

    ; Reset screen index and switch to cleaning state
    xor a, a
    ld [wTextScreenIndex], a
    ld a, TEXT_CLEANING
    ld [wTextState], a
    ret 

.cleanTiles
    ; Clean text tiles
    ld bc, $20
    ld hl, _VRAM + $1500
    ld a, [wTextScreenIndex]
    swap a ; a * 16
    add_r16_a h, l
    ld a, [wTextScreenIndex]
    swap a ; a * 16
    add_r16_a h, l ; a * 32
    ld a, $FF
    call memset

    ld a, [wTextScreenIndex]
    inc a
    ld [wTextScreenIndex], a
    cp a, 16 ; 512 / 32 = 16
    ret nz

    xor a, a
    ld [wTextScreenIndex], a
    ld a, TEXT_DRAWING
    ld [wTextState], a
    ld a, 144 - 40
    ldh [rWY], a
    ldh [rLYC], a
    ret

.drawing
    ; 10 Chars per line, 20 max.

    ld a, [wTextBank]
    swap_bank

    ld b, b

    ; This is messy and dumb, I know. But it's only a few (2) extra cycles to save 2 bytes of ram
    ld a, [wTextPointer]
    ld h, a
    ld a, [wTextPointer + 1]
    ld l, a
    inc hl
    ld a, h
    ld [wTextPointer], a
    ld a, l
    ld [wTextPointer + 1], a
    dec hl
    ; hl now points to next ascii character to print.
    ld a, [hl]
    cp a, "@"
    jr z, .return
    cp a, "\n"
    jr z, .newLine
    cp a, SPCHAR_QUESTION
    jr z, .returnAsk

    
    swap a ; a * 16 (In a way, you'll see :) )
    ld e, a ; Save a
    ld hl, GameFont - ($20 * 16) ; We start on ascii character 32 (space), so we need to subtract 32 * 16 as an offset.
    and a, %11110000
    add_r16_a h, l
    ld a, e
    and a, %00001111
    add a, h
    ld h, a ; This multiplies the offset by 16
    ; hl now points to the tile we need to copy.

    ld a, BANK(GameFont)
    swap_bank

    ld a, [wTextScreenIndex]
    swap a
    ld e, a
    and $0F
    add a, HIGH(vTextTiles)
    ld d, a
    ld a, e
    and $F0
    ASSERT LOW(vTextTiles) == 0
    ; add a, LOW(vTextTiles)
    ld e, a

    ld c, $10
    rst memcopy_small

    ld a, [wTextScreenIndex]
    inc a
    ld [wTextScreenIndex], a
    cp a, $20
    ret nz
.return
    ld a, TEXT_WAITING
    ld [wTextState], a
    ret
.returnAsk
    ld a, TEXT_ASK
    ld [wTextState], a
    xor a, a
    ld [wTextAnswer], a
    ret
.newLine
    ld a, [wTextScreenIndex]
    ; If we're past line 1
    cp a, 16
    jr c, .nextLine
    ld a, TEXT_WAITING
    ld [wTextState], a
    ret
.nextLine
    ld a, 16
    ld [wTextScreenIndex], a
    ret

.waiting 
    ldh a, [hNewKeys]
    bit PADB_A, a
    ret z ; No input? Keep waiting...

    ld a, [wTextBank]
    swap_bank

    ld a, [wTextPointer]
    ld h, a
    ld a, [wTextPointer + 1]
    ld l, a
    dec hl ; Check what character got us here.
    ld a, [hl]
    cp a, "@"
    jr z, .close
    ; If it wasn't an "@", we must be waiting for the next line!
    ; Reset screen index and switch to cleaning state
    xor a, a
    ld [wTextScreenIndex], a
    ld a, TEXT_CLEANING
    ld [wTextState], a
    ret

.close
    ; TODO: Lower the window. The UI may fix this, so remove this if that happens
    ld a, 144 - 16
    ldh [rWY], a
    ldh [rLYC], a
    ; Let scripting know we're done
    ld [wTextScriptFinished], a
    ASSERT TEXT_HIDDEN == 0
    xor a, a
    ld [wTextState], a
    ret

.ask
    ; Start by switching answers if needed
    ld hl, wTextAnswer
    ldh a, [hNewKeys]
    and a, $F0 ; All directions will have the same effect, so...
    jr z, .cursorDraw
    ld a, [hl]
    and a, a
    jr z, .switch1
    xor a, a
    ld [hl], a
    jr .cursorDraw
.switch1
    inc [hl]
.cursorDraw
    ld a, [hl]
    and a, a
    jr nz, .cursorDraw1
.cursorDraw0
    ld c, $10
    ld de, vTextTiles + $0100
    ld hl, GameFont - ($20 * 16) + (" " * 16) ; Copy "-" to the second row.
    rst memcopy_small
    ld c, $10
    ld de, vTextTiles
    ld hl, GameFont - ($20 * 16) + (">" * 16) ; Copy ">" to the first row.
    rst memcopy_small
    jr .acceptCheck
.cursorDraw1
    ld c, $10
    ld de, vTextTiles
    ld hl, GameFont - ($20 * 16) + (" " * 16) ; Copy "-" to the first row.
    rst memcopy_small
    ld c, $10
    ld de, vTextTiles + $0100
    ld hl, GameFont - ($20 * 16) + (">" * 16) ; Copy ">" to the second row.
    rst memcopy_small
.acceptCheck
    ldh a, [hNewKeys]
    bit PADB_A, a
    jr nz, .close
    ret


SECTION "Dialogue", ROMX

; Used to design the textbox.
TextboxMap::
    db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F
    db $7F, $7F, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $7F, $7F
    db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F
    db $7F, $7F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $7F, $7F
    db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F

DebugOh::
    db "Oh?"
    end_text

DebugHello::
    db "Hello. How're\n"
    db "you?"
    end_text

DebugGoodbye::
    say "See ya!\n"
    say " $ $ $ $\n"
    
    say "... why haven't\n"
    say "you left yet?\n"

    ask "Not ready\n"
    ask "I like you :3"
    end_ask

SECTION "Text Variables", WRAM0

; See text.inc TEXT_* constants. Set to TEXT_START to draw from wTextPointer
wTextState::
    ds 1

; Pointer to the next character.
wTextBank::
    ds 1
wTextPointer::
    ds 2

; Where are we on the screen?
wTextScreenIndex::
    ds 1

; What's the answer to the current question? (0 or 1)
wTextAnswer::
    ds 1