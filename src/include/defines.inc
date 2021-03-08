
; ### Sprites ###

    IF !DEF(DEFINES_INC)
DEFINES_INC SET 1

; Max number of sprites
MAXIMUM_SPRITES EQU 40 

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

; Metasprite end byte
METASPRITE_END EQU $64

; Length of most RAM
RAM_LENGTH  EQU $2000

; Direction constants
DIRECTION_DOWN EQU 1
DIRECTION_UP EQU 2
DIRECTION_RIGHT EQU 3
DIRECTION_LEFT EQU 4
; Starting from 0 for offsets
DIR_OFFSET_DOWN EQU 0
DIR_OFFSET_UP EQU 1
DIR_OFFSET_RIGHT EQU 2
DIR_OFFSET_LEFT EQU 3

    ENDC
