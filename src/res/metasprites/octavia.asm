INCLUDE "graphics.inc"
INCLUDE "hardware.inc"

SECTION "Octavia Metasprites", ROMX

OctaviaMetasprites::
    ; Still
    .down       DW .spriteDown
    .up         DW .spriteUp
    .right      DW .spriteRight
    .left       DW .spriteLeft
    ; Step
    .downStep   dw .spriteDownStep
    .upStep     DW .spriteUpStep
    .rightStep  dw .spriteRightStep
    .leftStep   dw .spriteLeftStep
    ; Swing
    .downSwing  dw .spriteDownSwing
    .upSwing    DW .spriteUpSwing
    .rightSwing dw .spriteRightSwing
    .leftSwing  dw .spriteLeftSwing
    ; Grab
    .downGrab  dw .spriteDownGrab
    .upGrab    DW .spriteUpGrab
    .rightGrab dw .spriteRightSwing ; Side swing and
    .leftGrab  dw .spriteLeftSwing ; grab are the same

.spriteDown::
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_DOWN_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_DOWN_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteUp::
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_UP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_UP_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteRight::
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_RIGHT_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_RIGHT_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteLeft:: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_RIGHT_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_RIGHT_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END

; Steps

.spriteDownStep:: ; Flipped version
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_DOWN_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_DOWN_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END


.spriteUpStep:: ; Flipped version
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_UP_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_UP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END


.spriteRightStep::
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_RIGHT_STEP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_RIGHT_STEP_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteLeftStep:: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_RIGHT_STEP_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_RIGHT_STEP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END

; Swings

.spriteDownSwing::
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_DOWN_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_DOWN_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB METASPRITE_END

.spriteUpSwing::
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_UP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_UP_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteRightSwing::
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_RIGHT_STEP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_RIGHT_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteLeftSwing:: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_RIGHT_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_RIGHT_STEP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END

.spriteDownGrab::
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_DOWN_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_DOWN_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END

.spriteUpGrab::
    DB -8 ; y
    DB -8 ; x
    DB TILE_OCTAVIA_UP_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_OCTAVIA_UP_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_BANK0 ; Flags

    DB METASPRITE_END
