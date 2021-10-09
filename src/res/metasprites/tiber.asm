INCLUDE "graphics.inc"
INCLUDE "hardware.inc"

SECTION "Tiber Metasprites", ROMX

TiberMetasprites::
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
    ; Sword
    .downSword  dw .spriteDownSword
    .upSword    DW .spriteUpSword
    .rightSword dw .spriteRightSword
    .leftSword  dw .spriteLeftSword
    ; Sword Swoosh
    .downSwoosh  dw .spriteDownSwoosh
    .upSwoosh    DW .spriteUpSwoosh
    .rightSwoosh dw .spriteRightSwoosh
    .leftSwoosh  dw .spriteLeftSwoosh

.spriteDown:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_DOWN_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_DOWN_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END


.spriteUp:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_UP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_UP_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END


.spriteRight:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_RIGHT_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_RIGHT_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END


.spriteLeft: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_RIGHT_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_RIGHT_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END

; Steps

.spriteDownStep: ; Flipped version
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_DOWN_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_DOWN_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END


.spriteUpStep: ; Flipped version
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_UP_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_UP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END


.spriteRightStep:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_RIGHT_STEP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_RIGHT_STEP_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END


.spriteLeftStep: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_RIGHT_STEP_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_RIGHT_STEP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END

; Swings

.spriteDownSwing:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_DOWN_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_DOWN_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END

.spriteUpSwing:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_UP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_UP_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END


.spriteRightSwing:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_RIGHT_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_RIGHT_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END


.spriteLeftSwing: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_RIGHT_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_RIGHT_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END

.spriteDownGrab
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_DOWN_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_DOWN_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END

.spriteUpGrab
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_UP_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_UP_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END

; Swords

.spriteDownSword:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_DOWN_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_DOWN_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB 6 ; y
    DB -8 ; x
    DB TILE_SWORD_UP
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_YFLIP

    DB METASPRITE_END

.spriteUpSword:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_UP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_UP_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -22 ; y
    DB 1 ; x
    DB TILE_SWORD_UP
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB METASPRITE_END


.spriteRightSword:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_RIGHT_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_RIGHT_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -4 ; y
    DB 6 ; x
    DB TILE_SWORD_RIGHT_HANDLE
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB -4 ; y
    DB 14 ; x
    DB TILE_SWORD_RIGHT_POINT
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB METASPRITE_END


.spriteLeftSword: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_RIGHT_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_RIGHT_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -4 ; y
    DB -14 ; x
    DB TILE_SWORD_RIGHT_HANDLE
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    DB -4 ; y
    DB -22 ; x
    DB TILE_SWORD_RIGHT_POINT
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    DB METASPRITE_END


; Swooshs

.spriteDownSwoosh:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_DOWN_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_DOWN_2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB 6 ; y
    DB -8 ; x
    DB TILE_SWORD_UP
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_YFLIP

    DB 10 ; y
    DB 0 ; x
    DB TILE_SWORD_SWOOSH
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB METASPRITE_END

.spriteUpSwoosh:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_UP_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_UP_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -22 ; y
    DB 1 ; x
    DB TILE_SWORD_UP
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB -26 ; y
    DB -7 ; x
    DB TILE_SWORD_SWOOSH
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP | OAMF_YFLIP

    DB METASPRITE_END


.spriteRightSwoosh:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_RIGHT_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_RIGHT_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -4 ; y
    DB 6 ; x
    DB TILE_SWORD_RIGHT_HANDLE
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB -4 ; y
    DB 14 ; x
    DB TILE_SWORD_RIGHT_POINT
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB -12 ; y
    DB 14 ; x
    DB TILE_SWORD_SWOOSH
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_YFLIP

    DB METASPRITE_END


.spriteLeftSwoosh:
    DB -8 ; y
    DB -8 ; x
    DB TILE_TIBER_RIGHT_ACT ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB TILE_TIBER_RIGHT_1 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -4 ; y
    DB -14 ; x
    DB TILE_SWORD_RIGHT_HANDLE
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    DB -4 ; y
    DB -22 ; x
    DB TILE_SWORD_RIGHT_POINT
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    DB -12 ; y
    DB -22 ; x
    DB TILE_SWORD_SWOOSH
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP | OAMF_YFLIP

    DB METASPRITE_END
