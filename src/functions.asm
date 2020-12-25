
; Contains common global functions

SECTION "Overwrite Bytes", ROM0

; Overwrites a certain amount of bytes with a single byte, only works if bc is > $FF
; @ arguments:
; @  a: source
; @ bc: length
; @ hl: destination
; @ return:
; @  a: a
; @ bc: $00
; @ hl: hl + bc + 1
OverwriteBytes::
	inc b
	inc c
	jr .decCounter
.loadByte
	ld [hli],a
.decCounter
	dec c
	jr nz, .loadByte
	dec b
	jr nz, .loadByte
	ret


SECTION "Copy Bytes", ROM0

; Copies a certain amount of bytes from one location to another
; @ arguments:
; @ bc: length
; @ de: destination
; @ hl: source
; @ return:
; @  a: final byte copied
; @ bc: $00
; @ cd: cd + bc + 1
; @ hl: hl + bc + 1
;CopyBytes::
    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, CopyBytes
    dec b
    ld c, $FF
    jr nz, CopyBytes
    ret

CopyBytes::
	inc b
	inc c
	jr .decCounter
.loadByte
    ld a, [hli]
	ld [de], a
    inc de
.decCounter
	dec c
	jr nz, .loadByte
	dec b
	jr nz, .loadByte
	ret


SECTION "Call hl", ROM0 

;call hl

_hl_::
    jp hl

_ret_::
    ret