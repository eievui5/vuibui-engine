include "include/hardware.inc"
include "include/defines.inc"

;Bytes 1 and 2 are X and Y offsets for the Metasprite.
;Byte 3 is the tile used by the Metasprite.
;Byte 4 is the attributes, listed below
;7: Render priority
;6: Y flip
;5: X flip
;4: Pallete number bit   (DMG only)
;3: VRAM bank            (GB Color only)
;2: Palette number bit 3 (GB Color only)
;1: Palette number bit 2 (GB Color only)
;0: Palette number bit 1 (GB Color only)

OCTAVIA_DOWN_1 EQU $00
OCTAVIA_DOWN_2 EQU $02
OCTAVIA_UP_1 EQU $04
OCTAVIA_UP_2 EQU $06
OCTAVIA_RIGHT_1 EQU $08
OCTAVIA_RIGHT_2 EQU $0A
OCTAVIA_RIGHT_STEP_1 EQU $0C
OCTAVIA_RIGHT_STEP_2 EQU $0E

SECTION "Metasprites", ROMX

; Octavia

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


OctaviaRight::
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


OctaviaLeft:: ; Flipped version of OctaviaRight
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

OctaviaDownStep:: ; Flipped version
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END


OctaviaUpStep:: ; Flipped version
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END


OctaviaRightStep::
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_STEP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_STEP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


OctaviaLeftStep:: ; Flipped version of OctaviaRight
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_STEP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_STEP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END
