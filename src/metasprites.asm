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

SECTION "Metasprites", ROMX

PlayerMetasprite::
    ; Player Sprite
    db $11 ; y
    db $09 ; x
    db $01
    db %00000000
