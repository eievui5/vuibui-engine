INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"

SECTION "Tiber Metasprites", ROMX

TiberMetasprites::
    ; Still
    .down       dw .spriteDown
    .up         dw .spriteUp
    .right      dw .spriteRight
    .left       dw .spriteLeft
    ; Step
    .downStep   dw .spriteDownStep
    .upStep     dw .spriteUpStep
    .rightStep  dw .spriteRightStep
    .leftStep   dw .spriteLeftStep
    ; Swing
    .downSwing  dw .spriteDownSwing
    .upSwing    dw .spriteUpSwing
    .rightSwing dw .spriteRightSwing
    .leftSwing  dw .spriteLeftSwing
    ; Grab
    .downGrab  dw .spriteDownGrab
    .upGrab    dw .spriteUpGrab
    .rightGrab dw .spriteRightSwing ; Side swing and 
    .leftGrab  dw .spriteLeftSwing ; grab are the same
    ; Sword
    .downSword  dw .spriteDownSword
    .upSword    dw .spriteUpSword
    .rightSword dw .spriteRightSword
    .leftSword  dw .spriteLeftSword
    ; Sword Swoosh
    .downSwoosh  dw .spriteDownSwoosh
    .upSwoosh    dw .spriteUpSwoosh
    .rightSwoosh dw .spriteRightSwoosh
    .leftSwoosh  dw .spriteLeftSwoosh
    
.spriteDown:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_DOWN_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_DOWN_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db METASPRITE_END


.spriteUp:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_UP_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_UP_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db METASPRITE_END


.spriteRight:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_RIGHT_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db METASPRITE_END


.spriteLeft: ; Flipped version of .spriteRight
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_RIGHT_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db METASPRITE_END

; Steps

.spriteDownStep: ; Flipped version
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_DOWN_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_DOWN_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db METASPRITE_END


.spriteUpStep: ; Flipped version
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_UP_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_UP_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db METASPRITE_END


.spriteRightStep:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_RIGHT_STEP_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_RIGHT_STEP_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db METASPRITE_END


.spriteLeftStep: ; Flipped version of .spriteRight
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_RIGHT_STEP_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_RIGHT_STEP_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db METASPRITE_END

; Swings

.spriteDownSwing:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_DOWN_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db METASPRITE_END

.spriteUpSwing:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_UP_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_UP_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db METASPRITE_END


.spriteRightSwing:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_RIGHT_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db METASPRITE_END


.spriteLeftSwing: ; Flipped version of .spriteRight
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_RIGHT_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db METASPRITE_END

.spriteDownGrab
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db METASPRITE_END

.spriteUpGrab
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_UP_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_UP_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db METASPRITE_END

; Swords

.spriteDownSword:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_DOWN_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db 6 ; y
    db -8 ; x
    db TILE_SWORD_UP
    db OAMF_PAL0 | DEFAULT_BLUE | OAMF_YFLIP

    db METASPRITE_END

.spriteUpSword:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_UP_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_UP_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -22 ; y
    db 1 ; x
    db TILE_SWORD_UP
    db OAMF_PAL0 | DEFAULT_BLUE 

    db METASPRITE_END


.spriteRightSword:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_RIGHT_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -4 ; y
    db 6 ; x
    db TILE_SWORD_RIGHT_HANDLE
    db OAMF_PAL0 | DEFAULT_BLUE
    
    db -4 ; y
    db 14 ; x
    db TILE_SWORD_RIGHT_POINT
    db OAMF_PAL0 | DEFAULT_BLUE

    db METASPRITE_END


.spriteLeftSword: ; Flipped version of .spriteRight
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_RIGHT_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db -4 ; y
    db -14 ; x
    db TILE_SWORD_RIGHT_HANDLE
    db OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP
    
    db -4 ; y
    db -22 ; x
    db TILE_SWORD_RIGHT_POINT
    db OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    db METASPRITE_END

    
; Swooshs

.spriteDownSwoosh:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_DOWN_2 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db 6 ; y
    db -8 ; x
    db TILE_SWORD_UP
    db OAMF_PAL0 | DEFAULT_BLUE | OAMF_YFLIP

    db 10 ; y
    db 0 ; x
    db TILE_SWORD_SWOOSH
    db OAMF_PAL0 | DEFAULT_BLUE

    db METASPRITE_END

.spriteUpSwoosh:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_UP_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_UP_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -22 ; y
    db 1 ; x
    db TILE_SWORD_UP
    db OAMF_PAL0 | DEFAULT_BLUE

    db -26 ; y
    db -7 ; x
    db TILE_SWORD_SWOOSH
    db OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP | OAMF_YFLIP

    db METASPRITE_END


.spriteRightSwoosh:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_RIGHT_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED ; Flags

    db -4 ; y
    db 6 ; x
    db TILE_SWORD_RIGHT_HANDLE
    db OAMF_PAL0 | DEFAULT_BLUE
    
    db -4 ; y
    db 14 ; x
    db TILE_SWORD_RIGHT_POINT
    db OAMF_PAL0 | DEFAULT_BLUE

    db -12 ; y
    db 14 ; x
    db TILE_SWORD_SWOOSH
    db OAMF_PAL0 | DEFAULT_BLUE | OAMF_YFLIP

    db METASPRITE_END


.spriteLeftSwoosh:
    db -8 ; y
    db -8 ; x
    db TILE_TIBER_RIGHT_ACT ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db TILE_TIBER_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | DEFAULT_RED | OAMF_XFLIP ; Flags

    db -4 ; y
    db -14 ; x
    db TILE_SWORD_RIGHT_HANDLE
    db OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP
    
    db -4 ; y
    db -22 ; x
    db TILE_SWORD_RIGHT_POINT
    db OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP

    db -12 ; y
    db -22 ; x
    db TILE_SWORD_SWOOSH
    db OAMF_PAL0 | DEFAULT_BLUE | OAMF_XFLIP | OAMF_YFLIP

    db METASPRITE_END
