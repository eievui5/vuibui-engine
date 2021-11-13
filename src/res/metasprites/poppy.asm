INCLUDE "graphics.inc"
INCLUDE "hardware.inc"

SECTION "Poppy Metasprites", ROMX

PoppyMetasprites::
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

.spriteDown:
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyDown + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteUp:
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyUp + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteRight:
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyRight + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteLeft: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyRight + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END

; Steps

.spriteDownStep: ; Flipped version
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyDown + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END


.spriteUpStep: ; Flipped version
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyUp + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END


.spriteRightStep:
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyRightStep + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteLeftStep: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyRightStep + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END

; Swings

.spriteDownSwing:
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyActDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyDown + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB METASPRITE_END

.spriteUpSwing:
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyActUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteRightSwing:
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyActRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB METASPRITE_END


.spriteLeftSwing: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyActRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END

.spriteDownGrab
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyActDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyActDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB METASPRITE_END

.spriteUpGrab
    DB -8 ; y
    DB -8 ; x
    DB idof_vPoppyActUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vPoppyActUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_GREEN | OAMF_BANK0 ; Flags

    DB METASPRITE_END
