
    IF !DEF(SWITCH_INC)
DEF SWITCH_INC EQU 1

; Begin a switch statement. This will ultimately return, so please `call` your switch if this is unwanted.
; All you need to do is set `a` to the case value. VALUES ABOVE THE MAX CASE WILL NOT WORK!
MACRO switch
    IF DEF(SWITCH_INDEX)
        FAIL "Switch statements must be closed using `end_switch`!"
    ENDC
    call HandleJumpTable
    DEF SWITCH_INDEX = -1
ENDM

; Begin a switch statement with banks enabled
MACRO far_switch

    FAIL "You haven't implemented a far jumptable yet!"

    IF DEF(SWITCH_INDEX)
        FAIL "Switch statements must be closed using `end_switch`!"
    ENDC
    call HandleJumpTableFar
    DEF SWITCH_INDEX = -1
    DEF BANKED = 1
ENDM

; Add a case to the switch statement. The value must be 1 higher than the previous case.
; `case value, address`
MACRO case
    IF _NARG != 2
        FAIL "Expected 2 Args!"
    ENDC
    IF !DEF(SWITCH_INDEX)
        FAIL "`case` missing opening `switch`!"
    ENDC
    IF \1 != SWITCH_INDEX + 1
        FAIL "Switch statement out of order! Cases must be sequential."
    ENDC
    IF DEF(BANKED)
        db BANK(\2)
    ENDC
    dw \2
    DEF SWITCH_INDEX = SWITCH_INDEX + 1
ENDM

; Cleanup after a switch statement. This is required to use `switch` more than once.
MACRO end_switch
    IF !DEF(SWITCH_INDEX)
        FAIL "`end_switch` missing opening `switch`!"
    ENDC
    IF DEF(BANKED)
        PURGE BANKED
    ENDC
    PURGE SWITCH_INDEX
ENDM

    ENDC
