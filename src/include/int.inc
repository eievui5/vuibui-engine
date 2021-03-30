    IF !DEF(INT_INC)
INT_INC SET 1

INCLUDE "structs.inc"

DEF min_u8 EQU 0
DEF max_u8 EQU 255
DEF sizeof_u8 EQU 1
MACRO u8
    bytes 1, \1
ENDM

DEF min_u16 EQU 0
DEF max_u16 EQU 65535
DEF sizeof_u16 EQU 2
MACRO u16
    bytes 2, \1
ENDM

DEF min_i8 EQU -128
DEF max_i8 EQU 127
DEF sizeof_i8 EQU 1
MACRO i8
    bytes 1, \1
ENDM

DEF min_i16 EQU -32768
DEF max_i16 EQU 32767
DEF sizeof_i16 EQU 2
MACRO i16
    bytes 2, \1
ENDM

    ENDC