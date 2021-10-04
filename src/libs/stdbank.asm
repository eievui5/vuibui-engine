INCLUDE "hardware.inc"

SECTION "Swap Bank", ROM0[$0020]
; Sets rROMB0 and hCurrentBank to `a`
; @ a: Bank
SwapBank::
    ld [rROMB0], a
    ldh [hCurrentBank], a
    ret

SECTION "Far Call", ROM0[$0028]
; Calls a function in another bank
; @ b:  Target bank
; @ hl: Target function.
FarCall::
    ld a, [hCurrentBank]
    push af
    ld a, b
    rst SwapBank
    rst CallHL
    pop af
    jr SwapBank

SECTION "Memory Copy Far", ROM0
; Switches the bank before performing a copy.
; @ b:  bank
; @ c:  length
; @ de: destination
; @ hl: source
MemCopyFar::
    ld a, [hCurrentBank]
    push af
    ld a, b
    rst SwapBank
.copy
    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, .copy
    pop af
    rst SwapBank
    ret

SECTION "Current Bank", HRAM
hCurrentBank::
    ds 1