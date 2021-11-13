INCLUDE "graphics.inc"
INCLUDE "hardware.inc"

SECTION "Tiber Metasprites", ROMX

TiberMetasprites::
    ; Still
    DW .spriteDown
    DW .spriteUp
    DW .spriteRight
    DW .spriteLeft
    ; Step
    DW .spriteDownStep
    DW .spriteUpStep
    DW .spriteRightStep
    DW .spriteLeftStep
    ; Swing
    DW .spriteDownSwing
    DW .spriteUpSwing
    DW .spriteRightSwing
    DW .spriteLeftSwing
    ; Grab
    DW .spriteDownGrab
    DW .spriteUpGrab
    DW .spriteRightSwing ; Side swing and
    DW .spriteLeftSwing ; grab are the same
    ; Sword
    DW .spriteDownSword
    DW .spriteUpSword
    DW .spriteRightSword
    DW .spriteLeftSword
    ; Sword Swoosh
    DW .spriteDownSwoosh
    DW .spriteUpSwoosh
    DW .spriteRightSwoosh
    DW .spriteLeftSwoosh
    ; Shield
    DW .spriteDownShield
    DW .spriteUpSwing
    DW .spriteRightShield
    DW .spriteLeftShield

.spriteDown:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberDown + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END

.spriteUp:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberUp + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END

.spriteRight:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberRight + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END

.spriteLeft: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberRight + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END

; Steps

.spriteDownStep: ; Flipped version
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberDown + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END

.spriteUpStep: ; Flipped version
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberUp + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END

.spriteRightStep:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberRightStep + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END

.spriteLeftStep: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberRightStep + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END

; Swings

.spriteDownSwing:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberActDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberDown + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END

.spriteUpSwing:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberActUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END

.spriteRightSwing:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberActRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END

.spriteLeftSwing: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberActRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END

.spriteDownGrab
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberActDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberActDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB METASPRITE_END

.spriteUpGrab
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberActUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberActUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB METASPRITE_END

; Swords

.spriteDownSword:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberActDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberDown + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB 6 ; y
    DB -8 ; x
    DB idof_vSwordUp
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_YFLIP

    DB METASPRITE_END

.spriteUpSword:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberActUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -22 ; y
    DB 1 ; x
    DB idof_vSwordUp
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB METASPRITE_END

.spriteRightSword:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberActRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -4 ; y
    DB 6 ; x
    DB idof_vSwordRight
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB -4 ; y
    DB 14 ; x
    DB idof_vSwordRight + 2
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB METASPRITE_END

.spriteLeftSword: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberActRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -4 ; y
    DB -14 ; x
    DB idof_vSwordRight
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    DB -4 ; y
    DB -22 ; x
    DB idof_vSwordRight + 2
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    DB METASPRITE_END

; Swooshs

.spriteDownSwoosh:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberActDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberDown + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB 6 ; y
    DB -8 ; x
    DB idof_vSwordUp
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_YFLIP

    DB 10 ; y
    DB 0 ; x
    DB idof_vSwordSwoosh
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB METASPRITE_END

.spriteUpSwoosh:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberActUp ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -22 ; y
    DB 1 ; x
    DB idof_vSwordUp
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB -26 ; y
    DB -7 ; x
    DB idof_vSwordSwoosh
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP | OAMF_YFLIP

    DB METASPRITE_END

.spriteRightSwoosh:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberActRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -4 ; y
    DB 6 ; x
    DB idof_vSwordRight
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB -4 ; y
    DB 14 ; x
    DB idof_vSwordRight + 2
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB -12 ; y
    DB 14 ; x
    DB idof_vSwordSwoosh
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_YFLIP

    DB METASPRITE_END

.spriteLeftSwoosh:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberActRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -4 ; y
    DB -14 ; x
    DB idof_vSwordRight
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    DB -4 ; y
    DB -22 ; x
    DB idof_vSwordRight + 2
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    DB -12 ; y
    DB -22 ; x
    DB idof_vSwordSwoosh
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP | OAMF_YFLIP

    DB METASPRITE_END

; Shields

.spriteDownShield:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberActDown ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberDown + 2 ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -2 ; y
    DB -9 ; x
    DB idof_vShield
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB -2 ; y
    DB -1 ; x
    DB idof_vShield + 2
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB METASPRITE_END

.spriteRightShield:
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberActRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED ; Flags

    DB -6 ; y
    DB 4 ; x
    DB idof_vShieldSide
    DB OAMF_PAL0 | DEFAULT_BLUE

    DB METASPRITE_END

.spriteLeftShield: ; Flipped version of .spriteRight
    DB -8 ; y
    DB -8 ; x
    DB idof_vTiberActRight ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -8 ; y
    DB 0 ; x
    DB idof_vTiberRightStep ; Tile ID
    DB OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    DB -6 ; y
    DB -12 ; x
    DB idof_vShieldSide
    DB OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    DB METASPRITE_END
