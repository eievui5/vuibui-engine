
INCLUDE "include/sfx.inc"

; 7654 3210  Segment header ($00-$EF)
; |||| ++++- segment duration (0: 1 frame; 15: 16 frames)
; |||+------ 1: pitch change follows
; ||+------- 1: deep parameter follows
; ++-------- quick parameter
;
; If deep parameter and pitch change are used together, deep parameter comes first.

; 7654 3210  Pulse/noise deep parameter: Envelope
; |||| ||||
; |||| |+++- Decay period (0: no decay; 1-7: frames per change)
; |||| +---- Decay direction (0: -1; 1: +1)
; ++++------ Starting volume (0: mute; 1-15: linear)
;
; For sound effects, pitch is an offset in semitones above the lowest supported pitch, which is low C (65.4 Hz).

;7654 3210  Noise pitch parameter
;|||| |+++- Period divider r (1, 2, 4, 6, 8, 10, 12, 14)
;|||| +---- Periodic flag (0: 32767 steps, more noise-like;
;||||       1: 127 steps; more tone-like)
;++++------ Period prescaler s

; Channels
DEF PULSE1 EQU 0
DEF PULSE2 EQU 1
DEF WAVE EQU 2
DEF NOISE EQU 3

; Segments
; Define the next byte as an envelope deep parameter.
DEF ENVF_DPAR EQU $20
; Define the next byte as am envelope pitch parameter.
DEF ENVF_PITCH EQU $10

; Pulse Channel:
DEF PULQ_DUTY8 EQU 0 << 6
DEF PULQ_DUTY4 EQU 1 << 6
DEF PULQ_DUTY2 EQU 2 << 6
DEF PUL_DECAY_DOWN EQU 0
DEF PUL_DECAY_UP EQU 1

; Wave Channel:
DEF WAVQ_VOLUME1 EQU 0 << 6
DEF WAVQ_VOLUME2 EQU 1 << 6
DEF WAVQ_VOLUME4 EQU 2 << 6
DEF WAVQ_VOLUME0 EQU 3 << 6

; Noise Channel
DEF NOIP_PER_NOISE EQU 0
DEF NOIP_PER_TONE EQU 1

DEF SOUND_COUNTER = 0
; Define a new sound.
; @ dsound channel, sound
MACRO dsound
    IF _NARG != 3
        FAIL "Expected sound ID, channel, and effect as arguments!"
    ENDC
    DEF SOUND_NAME EQUS "SOUND_\1"
    IF SOUND_COUNTER != SOUND_NAME
        FAIL "SOUND_\1 (ID: {SOUND_NAME}) is at the incorrect index: \
              {SOUND_COUNTER}"
    ENDC
    PURGE SOUND_NAME
    REDEF SOUND_COUNTER = SOUND_COUNTER + 1
    db \2, 0
    dw \3
ENDM

; Define a volume envelope byte
; @ volume volume, [direction], [speed]
MACRO volume
    IF _NARG == 1
        db \1 << 4
    ELIF _NARG == 2
        IF \2 >= 0
            db \1 << 4 | 1 << 3 | \2
        ELSE
            db \1 << 4 | 0 << 3 | 0 - \2
        ENDC
    ELSE
        FAIL "Expected either 1 or 2 args!"
    ENDC
ENDM

; Defines a noise pitch
; @ noise prescaler, divider, per_flag
MACRO noise
    IF _NARG != 3
        FAIL "Expected 3 arguments!"
    ENDC
    IF \1 > 15
        FAIL "Prescalar must be from 0 to 15!"
    ENDC
    IF \3 > 1
        FAIL "Periodic flag must be boolean!"
    ENDC
    IF \2 > 7
        FAIL "Divider must be from 0 to 7!"
    ENDC
    db \1 << 4 | \3 << 3 | \2
ENDM

MACRO end_sound
    db -1
ENDM

SECTION "Sound Effects", ROMX, ALIGN[4]

sfx_table::
    dsound FLAME, NOISE, SoundFlame
    dsound ICE_SPELL, NOISE, SoundFlame
    dsound SHOCK_SPELL, NOISE, SoundLightning
    dsound HEAL_SPELL, NOISE, SoundFlame

wavebank::
    ; Toothy Wave
    db $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0

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
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 0
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 1
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 2
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 3
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 4
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 5
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 6
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 7
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 8
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 9
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 10
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 11
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 12
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 13
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 14
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 15
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 16
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 17
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 18
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 19
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 20
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 21
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 22
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 23
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 24
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 25
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 26
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 27
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 28
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 29
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 30
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 31
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 32
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 33
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 34
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 35
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 36
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 37
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 38
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 39
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 40
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 41
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 42
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 43
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 44
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 45
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 46
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 47
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 48
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 49
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 50
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 51
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 52
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 53
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 54
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 55
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 56
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 57
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 58
    db ENVF_DPAR| ENVF_PITCH | 1, 0, 59
    db $FF

SoundFlame:
    ; Noise Channel
    db ENVF_DPAR | ENVF_PITCH | 3
        volume 6, -3
        noise 8, 7, NOIP_PER_TONE
    db ENVF_PITCH | 3
        noise 7, 7, NOIP_PER_TONE
    db ENVF_PITCH | 3
        noise 6, 7, NOIP_PER_TONE
    db ENVF_PITCH | 3
        noise 7, 7, NOIP_PER_TONE
    end_sound

SoundLightning:
    ; Noise Channel
    db ENVF_DPAR | ENVF_PITCH | 15
        volume 10, -2
        noise 3, 6, NOIP_PER_NOISE
    end_sound
