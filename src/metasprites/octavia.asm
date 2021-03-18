INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"

SECTION "Octavia Metasprites", ROMX

OctaviaMetasprites::
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
    
.spriteDown:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteUp:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteRight:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteLeft: ; Flipped version of .spriteRight
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

.spriteDownStep: ; Flipped version
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END


.spriteUpStep: ; Flipped version
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END


.spriteRightStep:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_STEP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_STEP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteLeftStep: ; Flipped version of .spriteRight
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_STEP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_STEP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END

; Swings

.spriteDownSwing:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END

.spriteUpSwing:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteRightSwing:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteLeftSwing: ; Flipped version of .spriteRight
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END

.spriteDownGrab
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END

.spriteUpGrab
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END
