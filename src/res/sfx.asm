DEF ENVF_DPAR equ $20
DEF ENVF_PITCH equ $10

MACRO dsound
    IF _NARG != 2
        FAIL "Expected sound channel and effect as arguments!"
    ENDC
    db \1, 0
    dw \2
ENDM

SECTION "Sound Effects", ROMX, ALIGN[4]

sfx_table::
    dsound 3, fx_roll
    dsound 0, fx_jump
    dsound 0, fx_land
    dsound 0, fx_fall
    dsound 3, fx_rolltojump
    dsound 1, fx_point
    dsound 1, fx_complete
    dsound 0, fx_launch
  
    dsound 3, fx_land2
    dsound 1, fx_achieve
    dsound 1, fx_combostop
    dsound 3, fx_lowcombo_bonk
  
    dsound 2, fx_wavetest

  fx_roll:
    db ENVF_DPAR|ENVF_PITCH|1, $10, $6E
    db ENVF_PITCH|7, $64
    db ENVF_PITCH|5, $57
    db ENVF_PITCH|7, $64
    db ENVF_PITCH|5, $57
  fx_land2:
    db ENVF_DPAR|ENVF_PITCH|5, $10, $6C
    db ENVF_PITCH|2, $65
    db ENVF_PITCH|1, $66
    db ENVF_PITCH|1, $67
    db $FF
  fx_rolltojump:
    db ENVF_DPAR|ENVF_PITCH|1, $10, $5E
    db ENVF_PITCH|2, $54
    db ENVF_DPAR|ENVF_PITCH|2, $50, $25
    db $FF
  fx_jump:
    db ENVF_DPAR|ENVF_PITCH|$80, $59, 45
    db ENVF_PITCH|$80, 47
    db ENVF_PITCH|$80, 49
    db ENVF_DPAR|ENVF_PITCH|$80, $81, 51
    db ENVF_PITCH|$80, 53
    db ENVF_PITCH|$80, 55
    db ENVF_PITCH|$80, 56
    db ENVF_PITCH|$80, 57
    db $FF
  fx_land:
    db ENVF_DPAR|ENVF_PITCH|$80, $81, 16
    db ENVF_PITCH|$80, 12
    db ENVF_PITCH|$80, 9
    db ENVF_PITCH|$80, 7
    db ENVF_PITCH|$80, 5
    db ENVF_PITCH|$81, 3
    db ENVF_PITCH|$82, 2
    db $FF
  fx_fall:
    db ENVF_DPAR|ENVF_PITCH|$81, $4A, 57
    db ENVF_PITCH|$81, 56
    db ENVF_PITCH|$81, 55
    db ENVF_PITCH|$81, 54
    db ENVF_DPAR|ENVF_PITCH|$81, $80, 53
    db ENVF_PITCH|$81, 52
    db ENVF_PITCH|$81, 51
    db ENVF_PITCH|$81, 50
    db ENVF_DPAR|ENVF_PITCH|$81, $72, 49
    db ENVF_PITCH|$81, 48
    db ENVF_PITCH|$81, 47
    db ENVF_PITCH|$81, 46
    db $FF
  fx_point:
    db ENVF_DPAR|ENVF_PITCH|$84, $C1, 48
    db ENVF_DPAR|ENVF_PITCH|$88, $C1, 55
    db $FF
  fx_complete:
    db ENVF_DPAR|ENVF_PITCH|$43, $C1, 36
    db ENVF_DPAR|ENVF_PITCH|$43, $C1, 38
    db ENVF_DPAR|ENVF_PITCH|$43, $C1, 40
    db ENVF_DPAR|ENVF_PITCH|$43, $C1, 36
    db ENVF_DPAR|ENVF_PITCH|$43, $D1, 40
    db ENVF_DPAR|ENVF_PITCH|$43, $E1, 43
    db ENVF_DPAR|ENVF_PITCH|$43, $F1, 48
    db ENVF_PITCH|$41, 43
    db ENVF_PITCH|$43, 48
    db ENVF_PITCH|$41, 43
    db ENVF_PITCH|$41, 48
    db ENVF_PITCH|$41, 43
    db ENVF_PITCH|$41, 48
    db $FF
  fx_launch:
    db ENVF_DPAR|ENVF_PITCH|$80, $F1, 58
    db ENVF_PITCH|$40, 28
    db ENVF_PITCH|$8D, 26
    db $FF
  fx_achieve:
    db ENVF_DPAR|ENVF_PITCH|$81, $C1, 37
    db $42
    db $81
    db ENVF_DPAR|ENVF_PITCH|$43, $C1, 49
    db $42
    db $84
    db $FF
  fx_combostop:
    db ENVF_DPAR|ENVF_PITCH|$42, $A1, 31
    db ENVF_DPAR|ENVF_PITCH|$42, $A1, 36
    db ENVF_DPAR|ENVF_PITCH|$41, $A1, 40
    db $82
    db ENVF_DPAR|ENVF_PITCH|$42, $A1, 31
    db ENVF_DPAR|ENVF_PITCH|$42, $A1, 34
    db ENVF_DPAR|ENVF_PITCH|$41, $A1, 38
    db $86
    db $FF
  fx_lowcombo_bonk:
    db ENVF_DPAR|ENVF_PITCH|2, $43, $5D
    db ENVF_PITCH|2, $4D
    db $FF
  
  fx_wavetest:
    db ENVF_DPAR|ENVF_PITCH|$0F, $00, 24
    db $FF