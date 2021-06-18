INCLUDE "include/banks.inc"
INCLUDE "include/hardware.inc"

SECTION "Null", ROM0[$0000]
; null is equal to $0000. This should be used as a missing pointer value, and if
; called it will crash.
null::
    nop
    nop
    rst crash

SECTION "Call HL", ROM0[$0008]
; Used to call the address pointed to by `hl`. Mapped to `rst $08` or `rst CallHL`
CallHL::
    jp hl

SECTION "Memcopy Small", ROM0[$0010]

; A slightly faster version of memcopy that requires less setup but can only do
; up to 256 bytes. Destination and source are both offset by length, in case 
; you want to copy to or from multiple places
; @ c:  length
; @ de: destination
; @ hl: source
memcopy_small::
    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, memcopy_small
    ret

SECTION "Memset Small", ROM0[$0018]

; A slightly faster version of memset that requires less setup but can only do
; up to 256 bytes. Destination and source are both offset by length, in case 
; you want to copy to or from multiple places
; @ a:  source (is preserved)
; @ c:  length
; @ hl: destination
memset_small::
    ld [hli], a
    dec c
    jr nz, memset_small
    ret


SECTION "Swap Bank", ROM0[$0020]
; Sets rROMB0 and hCurrentBank to `a`
; @ a: Bank
SwapBank::
    ld [rROMB0], a
    ldh [hCurrentBank], a
    ret

SECTION "Crash Handler", ROM0[$0038]
crash:
    ld b, b
    di
    halt

SECTION "Overwrite Bytes", ROM0

; Overwrites a certain amount of bytes with a single byte. Destination is offset
; by length, in case you want to overwrite with different values.
; @ a:  source (is preserved)
; @ bc: length
; @ hl: destination
memset::
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

SECTION "Memory Copy", ROM0

; Copies a certain amount of bytes from one location to another. Destination and
; source are both offset by length, in case you want to copy to or from multiple
; places.
; @ bc: length
; @ de: destination
; @ hl: source
memcopy::
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



SECTION "Jump Table", ROM0

; Jumps the the `a`th pointer. 128 pointers max. Place pointers after the call
; using `dw`. This function is faster than a decrement table if there are 8 or
; more destinations, and is always smaller.
; @ a: Jump Offset
HandleJumpTable::
    ; Restore Pointer to jump table
    pop hl
    ; a * 2 (pointers are 2 bytes!)
    add a, a
    ; add hl, a
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; Load pointer into hl
    ld a, [hli] ; low byte
    ld h, [hl] ; high byte
    ld l, a
    ; Now jump!
    jp hl

SECTION "Call de", ROM0

; Calls the value in `de` by pushing it and returning
CallDE::
    push de
    ret

SECTION "LCD Memory", ROM0

; Waits for VRAM access before setting data.
; @ b:  source
; @ c:  length
; @ hl: destination
LCDMemsetSmall::
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, LCDMemsetSmall

	ld a, b
	ld [hli], a
	dec c
	jr nz, LCDMemsetSmall
	ret

; Waits for VRAM access before setting data.
; @ d:  source (is preserved)
; @ bc: length
; @ hl: destination
LCDMemset::
    inc b
    inc c
    jr .decCounter
.loadByte
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .loadByte

    ld a, d
    ld [hli], a
.decCounter
    dec c
    jr nz, .loadByte
    dec b
    jr nz, .loadByte
    ret

; Waits for VRAM access before copying data.
; @ c:  length
; @ de: destination
; @ hl: source
LCDMemcopySmall::
    ldh a, [rSTAT]
    and STATF_BUSY
    jr nz, LCDMemcopySmall

    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, LCDMemcopySmall
    ret

SECTION "Stack Slide", ROM0
; @ c:  Length / 2; each repetition is two bytes
; @ de: Source word
; @ hl: Destination (End of block; stack goes down!)
PushSlide::
    ld [wSlideStack], sp
    di ; Stack is about to die, disable interrupts

    ld sp, hl
.loop
    push de
    dec c
    jr nz, .loop

    ld hl, wSlideStack
    ld b, b
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld sp, hl
    ei ; Stack is back, enable.
    ret

SECTION "Slide Stack", WRAM0
wSlideStack::
    ds 2

SECTION "Farcall Byte", HRAM

hFarCallByte:
    ds 1