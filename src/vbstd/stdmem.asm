;
; This file is a part of the VuiBui Standard Library.
; The VuiBui standard library is an attempt at creating a collection of short,
; common functions that are universally useful to Game Boy programs.
;
; stdmem.asm
; Common memory operations like Copy and Set, as well as faster variations for
; blocks of data under 256 bytes.
;
; Copyright 2021 Eievui
; 
; This software is provided 'as-is', without any express or implied
; warranty.  In no event will the authors be held liable for any damages
; arising from the use of this software.
; 
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
; 
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.

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