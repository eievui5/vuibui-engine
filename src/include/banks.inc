    IF !DEF(BANKS_INC)
DEF BANKS_INC SET 1

INCLUDE "include/enum.inc"

DEF mSRAMEnable EQU $0000
DEF mBankSelect EQU $2000
;DEF mBankSelectHigh EQU $3000 ; Used for the upper 4 megabytes (not needed)
;DEF mSRAMBankSelect EQU $4000 

; Sets `mBankSelect` and `hCurrentBank` to `a`
MACRO swap_bank
    ld [mBankSelect], a
    ldh [hCurrentBank], a
ENDM

; Far pointer. Bank, then pointer.
MACRO far_pointer
    IF _NARG != 1
        FAIL "Expected 1 argument!"
    ENDC
    db BANK(\1)
    dw \1
ENDM

ENDC