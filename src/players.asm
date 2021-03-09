
INCLUDE "include/entities.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/defines.inc"
INCLUDE "include/players.inc"

OCTAVIA_DOWN_1 EQU $00
OCTAVIA_DOWN_2 EQU $02
OCTAVIA_UP_1 EQU $04
OCTAVIA_UP_2 EQU $06
OCTAVIA_RIGHT_1 EQU $08
OCTAVIA_RIGHT_2 EQU $0A
OCTAVIA_RIGHT_STEP_1 EQU $0C
OCTAVIA_RIGHT_STEP_2 EQU $0E

STEP_OFFSET EQU 4

SECTION "Player AI", ROMX

OctaviaPlayerLogic::
    ; Always start by offsetting frame by facing direction
    ld a, [wOctavia_Direction]
    ldh [hActiveEntityFrame], a

    ; Is this the active player?
    ld a, [wActivePlayer]
    ASSERT ACTIVE_PLAYER_OCTAVIA == 1
    dec a
    jr nz, .render ; For now, skip processing if the entity is not active.
.activeControl
    ; Check state. Can we move?

    ; TODO: Make modular and place in a fuction.
.activeMovement ; How to move.
    ; Reset velocity if we have control over movement
    xor a, a
    ld [wOctavia_YVel], a
    ld [wOctavia_XVel], a
    ; Are we even moving right now?
    ldh a, [hCurrentKeys]
    and a, $F0
    jr z, .render ; Let's not do anything if not.
    ; Every 32th tick (~ 1/2 second)...
    ld a, [wOctavia_Timer]
    inc a 
    ld [wOctavia_Timer], a
    bit 4, a 
    jr z, .activeMoveDown
    ; ...Offset to step animation
    ldh a, [hActiveEntityFrame]
    add a, STEP_OFFSET
    ldh [hActiveEntityFrame], a
.activeMoveDown
    ldh a, [hCurrentKeys]
    bit PADB_DOWN, a
    jr z, .activeMoveUp
    ld a, 1
    ld [wOctavia_YVel], a
    ; Update facing
    ASSERT DIR_OFFSET_DOWN == 0
    xor a, a
    ld [wOctavia_Direction], a
    ; Restore a
    ldh a, [hCurrentKeys] 
    ; Down and Up cannot be pressed, so skip to Left
    jr .activeMoveLeft
.activeMoveUp
    bit PADB_UP, a
    jr z, .activeMoveLeft
    ld a, -1
    ld [wOctavia_YVel], a
    ; Update facing
    ld a, DIR_OFFSET_UP
    ld [wOctavia_Direction], a
    ; Restore a
    ldh a, [hCurrentKeys] 
.activeMoveLeft
    bit PADB_LEFT, a
    jr z, .activeMoveRight
    ld a, -1
    ld [wOctavia_XVel], a
    ; Update facing
    ld a, DIR_OFFSET_LEFT
    ld [wOctavia_Direction], a
    ; Don't bother restoring a
    ; Left and Right cannot be pressed, so skip to Render
    jr .activeMoveAndSlide
.activeMoveRight
    bit PADB_RIGHT, a
    jr z, .activeMoveAndSlide
    ld a, 1
    ld [wOctavia_XVel], a
    ld a, DIR_OFFSET_RIGHT
    ld [wOctavia_Direction], a
    ; Don't bother restoring a
.activeMoveAndSlide
    ld hl, wOctavia_XVel
    call MoveAndSlide
.activeScroll
    ; Scroll
    ld a, [wOctavia_YPos]
    sub a, 80 + 8
    ld e, a
    ld a, [wOctavia_XPos]
    sub a, 72 + 8
    ld d, a
    call SetScrollBuffer
.render 
    ldh a, [hActiveEntityFrame] ; Load the active frame offset.
    ld h, a ; Save a
    swap a ; a * 16
    srl a ; a * 8
    add a, h ; a * 9
    ; Metasprites are 9 bytes long.
    ld hl, OctaviaMetasprites
    add_r16_a h, l

    ld a, [wOctavia_YPos]
    ld b, a
    ld a, [wOctavia_XPos]
    ld c, a
    call RenderMetasprite
    ret

; Octavia
OctaviaMetasprites:
OctaviaDown::
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


OctaviaUp::
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


OctaviaRight:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


OctaviaLeft: ; Flipped version of OctaviaRight
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END

; Steps

OctaviaDownStep: ; Flipped version
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END


OctaviaUpStep: ; Flipped version
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END


OctaviaRightStep:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_STEP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_STEP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


OctaviaLeftStep: ; Flipped version of OctaviaRight
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_STEP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_STEP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END

SECTION "Player Variables", WRAM0

; The Character currently being controlled by the player. Used as an offset.
wActivePlayer::
    ds 1

wPlayerArray::
    dstruct Entity, wOctavia
    dstruct Entity, wPoppy
