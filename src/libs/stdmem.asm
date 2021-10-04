SECTION "Memory Copy", ROM0

; Copies a certain amount of bytes from one location to another. Destination and
; source are both offset by length, in case you want to copy to or from multiple
; places.
; @ bc: length
; @ de: destination
; @ hl: source
MemCopy::
    dec bc
    inc b
    inc c
.loop:
    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, .loop
    dec b
    jr nz, .loop
    ret

SECTION "Memory Copy Small", ROM0[$0010]

; A slightly faster version of memcopy that requires less setup but can only do
; up to 256 bytes. Destination and source are both offset by length, in case 
; you want to copy to or from multiple places
; @ c:  length
; @ de: destination
; @ hl: source
MemCopySmall::
    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, MemCopySmall
    ret

SECTION "Memory Set", ROM0

; Overwrites a certain amount of bytes with a single byte. Destination is offset
; by length, in case you want to overwrite with different values.
; @ a:  source (is preserved)
; @ bc: length
; @ hl: destination
MemSet::
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

SECTION "Memset Small", ROM0[$0018]

; A slightly faster version of memset that requires less setup but can only do
; up to 256 bytes. Destination and source are both offset by length, in case 
; you want to copy to or from multiple places
; @ a:  source (is preserved)
; @ c:  length
; @ hl: destination
MemSetSmall::
    ld [hli], a
    dec c
    jr nz, MemSetSmall
    ret