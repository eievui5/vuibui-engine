;
; This file is a part of the VuiBui Standard Library.
; The VuiBui standard library is an attempt at creating a collection of short,
; common functions that are universally useful to Game Boy programs.
;
; stdopt.asm
; Macros used to assert that optimizations are valid.
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

IF !DEF(STDOPT_INC)
DEF STDOPT_INC EQU 1

MACRO fall
    ASSERT _NARG == 1, "Expected 1 argument!"
    ASSERT @ == \1, "Fallthrough to \1 failed!"
ENDM

ENDC