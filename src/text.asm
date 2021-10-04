INCLUDE "banks.inc"
INCLUDE "engine.inc"
INCLUDE "graphics.inc"
INCLUDE "hardware.inc"
INCLUDE "lb.inc"
INCLUDE "stat.inc"
INCLUDE "text.inc"

SECTION "Text Box", ROM0

; Initiallize, render, and close the textbox.
HandleTextbox::
; Initialize textbox
    xor a, a
    ld [wTextScreenIndex], a
    ; Hide HUD
    ld a, 143
    ldh [rLYC], a
    
; Clean VRAM

    ld a, BANK(TextboxMap)
    rst SwapBank

    ; Map the window to textbox.
    ld hl, _SCRN1 + $300
    ld de, TextboxMap
    ld b, 5 ; Load 5 rows.
    call ScreenCopy

    ; Reset palettes on CGB.
    ldh a, [hSystem]
    and a, a
    jr z, .cleanTiles
        ld a, 1
        ldh [rVBK], a
        ld hl, _SCRN1 + $300
        lb bc, HUD_MAIN_PAL, 5 ; Load 5 rows.
        call ScreenSet
        xor a, a
        ldh [rVBK], a

.cleanTiles
    ; Clean text tiles
    ld bc, sizeof_TILE * 32
    ld hl, _VRAM + $1500
    ld d, $FF
    call VRAMSet

; Show Textbox
    ld a, 144 - 40
    ldh [rLYC], a

    ldh a, [hSystem]
    and a, a
    ld a, STATIC_FX_SHOW_HUD ; Show HUD on DMG
    jr z, :+
        ld a, STATIC_FX_TEXTBOX_PALETTE ; Use Hi-Color on CGB
:   ld [wStaticFX], a

.draw
    ; Wait for the next frame to draw another character.
:   xor a, a
    ld [wNewFrame], a
    halt
    ld a, [wNewFrame]
    and a, a
    jr z, :-

    ld a, [wTextBank]
    rst SwapBank

    ld hl, wTextPointer
    ld a, [hli]
    ld d, a
    ld a, [hld]
    ld e, a
    inc de
    ld a, d
    ld [hli], a
    ld [hl], e
    dec de
    ; de now points to next ascii character to print.
    ld a, [de]

    ; If the next character terminates the message, wait for input.
    ASSERT SPCHAR_TERMINATE == 0
    and a, a
    jr z, .wait
    cp a, "\n"
    jr z, .newLine
    cp a, SPCHAR_QUESTION
    jr z, .ask

    ld h, 0
    ld l, a
    ld bc, GameFont - (32 * 8) ; We start on ascii character 32 (space), so we need to subtract 32 * 8 as an offset.
    add hl, hl ; a * 2
    add hl, hl ; a * 4
    add hl, hl ; a * 8
    add hl, bc
    ; hl now points to the tile we need to copy.

    ld a, BANK(GameFont)
    rst SwapBank

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

    ld c, sizeof_1BPP
    call LCDComplement1bpp

    ld a, [wTextScreenIndex]
    inc a
    ld [wTextScreenIndex], a
    cp a, $20
    jr nz, .draw
    jr .wait

.newLine
    ld a, [wTextScreenIndex]
    ; If we're past line 1
    cp a, 16
    jr nc, .wait
.nextLine
    ld a, 16
    ld [wTextScreenIndex], a
    jr .draw

.wait
    ; Wait for the next frame to check input
:   xor a, a
    ld [wNewFrame], a
    halt
    ld a, [wNewFrame]
    and a, a
    jr z, :-

    ldh a, [hNewKeys]
    bit PADB_A, a
    jr z, :- ; No input? Keep waiting...

    ld a, [wTextBank]
    rst SwapBank

    ld a, [wTextPointer]
    ld h, a
    ld a, [wTextPointer + 1]
    ld l, a
    dec hl ; Check what character got us here.
    ld a, [hl]
    ASSERT SPCHAR_TERMINATE == 0
    and a, a ; cp a, SPCHAR_TERMINATE
    jr z, .close
    ; If it wasn't null, we must be waiting for the next line.
    ; Reset screen index and switch to cleaning state
    xor a, a
    ld [wTextScreenIndex], a
    jp .cleanTiles

.ask
    xor a, a
    ld [wTextAnswer], a

    ; Wait for the next frame to check input
:   xor a, a
    ld [wNewFrame], a
    halt
    ld a, [wNewFrame]
    and a, a
    jr z, :-

    ld a, BANK(GameFont)
    rst SwapBank

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
    ld c, 8
    ld de, vTextTiles + $0100
    get_character " "
    call LCDComplement1bpp
    ld c, 8
    ld de, vTextTiles
    get_character ">"
    call LCDComplement1bpp
    jr .acceptCheck
.cursorDraw1
    ld c, 8
    ld de, vTextTiles
    get_character " "
    call LCDComplement1bpp
    ld c, 8
    ld de, vTextTiles + $0100
    get_character ">"
    call LCDComplement1bpp
.acceptCheck
    ldh a, [hNewKeys]
    bit PADB_A, a
    jr z, :-

.close
    ; Reset keys to prevent misinputs.
    xor a, a
    ldh [hCurrentKeys], a
    ldh [hNewKeys], a
    jp ResetHUD

SECTION "Load Characters", ROM0

; Loads and unpacks a String. Useful for saving space in UI init. Expects string
; to be 0-terminated.
; @ hl: String
; @ de: destination
LoadCharacters::
    ldh a, [hCurrentBank]
    ld [rROMB0], a
    ld a, [hli]
    and a, a
    ret z
    push hl
        ; Offset to needed tile
        ld h, 0
        ld l, a
        ld a, BANK(GameFont)
        ld [rROMB0], a
        ld bc, GameFont - ($20 * 8) ; We start on ascii character 32 (space), so we need to subtract 32 * 8 as an offset.
        add hl, hl ; a * 2
        add hl, hl ; a * 4
        add hl, hl ; a * 8
        add hl, bc
        ld c, 8 ; Load 8 bytes
        call Unpack1bpp
    pop hl
    jr LoadCharacters

; Simplified version of LoadCharacters that draws the string on the screen.
; @ hDrawStringTileBase: ID of VRAM tile destination.
; @ bc: Null-terminated string.
; @ de: VRAM tile destination.
; @ hl: Tilemap destination.
DrawString::
    ldh a, [hCurrentBank]
    ldh [hDrawStringBank], a
.loop
    ldh a, [hDrawStringBank]
    rst SwapBank
    ld a, [bc]
    and a, a
    ret z
    inc bc
    push bc
    push hl
        ; We start on " " (space), so we need to subtract " " * 8 as an offset.
        ; `a` still needs to be multiplied to get to 8, so divide the
        ; address by 8 and adjust it later.
        ; 8 * (a + GameFont / 8) == 8a + GameFont
        add a, LOW(GameFont / 8 - " " + 1)
        ld l, a
        adc a, HIGH(GameFont / 8 - " " + 1)
        sub a, l
        ld h, a
        ; Now do the last of the multiplication.
        add hl, hl ; a * 2
        add hl, hl ; a * 4
        add hl, hl ; a * 8
        dec hl
        dec hl

        ld a, BANK(GameFont)
        rst SwapBank

        ld c, 8 ; Load 8 bytes
        call Unpack1bpp
    pop hl
    pop bc
    ; Now write the string to the tilemap.
.waitVRAM
    ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, .waitVRAM

    ldh a, [hDrawStringTileBase]
    ld [hli], a
    inc a
    ldh [hDrawStringTileBase], a
    jr .loop

SECTION "Dialogue", ROMX
; Used to design the textbox.
TextboxMap:: ; this is so dumb I have no words.
    db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F
    db $7F, $7F, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $7F, $7F
    db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F
    db $7F, $7F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $7F, $7F
    db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F

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

SECTION "Draw String", HRAM
; The ID of the VRAM tile destination for DrawString.
hDrawStringTileBase::
    ds 1
hDrawStringBank:
    ds 1