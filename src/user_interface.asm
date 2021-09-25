INCLUDE "include/banks.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/entity.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/lb.inc"
INCLUDE "include/stat.inc"
INCLUDE "include/text.inc"
INCLUDE "include/tiledata.inc"

DEF vPrintBar EQU $9F40
DEF vHUD EQU $9F60
DEF vAHint EQU $9F80
DEF vBHint EQU $9F83
DEF vHeartBar EQU $9F66

DEF CHARACTER_START_OFFSET EQU 20 ; How many tiles to skip for intial draw?
DEF SLIDE_IN_AMOUNT EQU 15 ; How many pixels before we've slid in?

SECTION "Heads Up Display", ROM0

ResetHUD::

    ld a, 1
    ldh [rVBK], a
    ld hl, vHUD
    lb bc, 7, 2 ; palette 7, 2 rows
    call ScreenSet
    xor a, a
    ldh [rVBK], a

    ld a, STATIC_FX_SHOW_HUD
    ld [wStaticFX], a
    ld a, 144 - 16 - 1
    ldh [rLYC], a

    ; Clear the HUD
    ld hl, vHUD
    lb bc, TILE_WHITE, 2 ; 2 rows
    call ScreenSet

    ; Load the button hints
    ld hl, vAHint

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, TILE_A_CHAR
    ld [hl], a
    ASSERT HIGH(vAHint) == HIGH(vBHint)
    ld l, LOW(vBHint)
    ASSERT TILE_A_CHAR + 1 == TILE_B_CHAR
    inc a
    ld [hl], a

    ; Signal to reset healthbars
    ld a, -1
    ld [wHUDActivePlayerBuffer], a

    ASSERT PalOctavia + sizeof_PALETTE == PalPoppy && PalPoppy + sizeof_PALETTE == PalTiber
    ASSERT sizeof_PALETTE == 12
    ld a, [wActivePlayer]
    add a, a ; a * 2
    add a, a ; a * 4
    ld c, a
    add a, c ; a * 8
    add a, c ; a * 12
    ; Add `a` to `PalOctavia` and store in `hl`
    add a, LOW(PalOctavia)
    ld l, a
    adc a, HIGH(PalOctavia)
    sub a, l
    ld h, a 
    ld de, wBCPD + sizeof_PALETTE * 7
    ld c, sizeof_PALETTE
    rst memcopy_small



    ret

UpdateHUD::

    ld a, [wActivePlayer]

    ld hl, wHUDActivePlayerBuffer
    cp a, [hl]
    jr nz, .redraw ; If the active player has changed, just redraw everything.

    ; Only animate healthbar every 4th frame
    ld a, [wFrameTimer]
    and a, %11
    ret nz

    ld a, [wActivePlayer]
    ; Get the active player's health
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ; Add `a` to `wPlayerArray + Entity_Health` and store in `hl`
    add a, LOW(wPlayerArray + Entity_Health)
    ld l, a
    adc a, HIGH(wPlayerArray + Entity_Health)
    sub a, l
    ld h, a 
    ld b, [hl]
    ; Get the last value we checked for health
    ld a, [wActivePlayer]
    ; Add `a` to `wHUDPlayerHealthBuffer` and store in `hl`
    add a, LOW(wHUDPlayerHealthBuffer)
    ld l, a
    adc a, HIGH(wHUDPlayerHealthBuffer)
    sub a, l
    ld h, a 
    ld a, [hl]
    cp a, b ; Compare last value to current value
    ret z ; return if no change is needed

    jr c, .heartIncrement
.heartDecrement
    ld b, TILE_HEART_EMPTY ; When hurting, hearts empty
    dec a
    jr .updateHeart
.heartIncrement
    ld b, TILE_HEART ; When healing, hearts get full
    inc a
.updateHeart
    ld [hl], a ; `hl` should still contin the health we want to reference, so restore that here.

    ; We need to clear carry before `rra`
    scf
    ccf

    rra
    jr nc, .skipHalf
    inc a ; Half hearts need to draw one off (basically, round up!)
    ld b, TILE_HEART_HALF
.skipHalf
    ld c, a
    ld a, TILE_HEART_EMPTY
    cp a, b
    ld a, c
    jr nz, :+
    inc a
:
    cp a, 10 + 1
    ld hl, vHeartBar - 1
    jr c, .skipBottom
    sub a, 10 
    ld hl, vHeartBar + 32 - 1
.skipBottom
    ; Add `a` to `hl`
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld [hl], b
    ret


.redraw

    ; Clear the HUD
    lb bc, TILE_WHITE, 10
    ld hl, vHeartBar
    call ScreenSet

    ldh a, [hSystem]
    and a, a
    jr z, .skipColor
    ASSERT PalOctavia + sizeof_PALETTE == PalPoppy && PalPoppy + sizeof_PALETTE == PalTiber
    ld a, [wActivePlayer]
    ASSERT sizeof_PALETTE == 12
    add a, a ; a * 2
    add a, a ; a * 4
    ld c, a
    add a, a ; a * 8
    add a, c ; a * 12
    ; Add `a` to `PalOctavia` and store in `hl`
    add a, LOW(PalOctavia)
    ld l, a
    adc a, HIGH(PalOctavia)
    sub a, l
    ld h, a 
    ld de, wBCPD + sizeof_PALETTE * 7
    ld c, sizeof_PALETTE
    rst memcopy_small
    
    ld a, PALETTE_STATE_RESET
    ld [wPaletteState], a

.skipColor

    ld a, [wActivePlayer]
    ld e, a ; save for later!

    ; Reset Health Bar (max health)
    ld b, 10
    ; Add `a` to `wPlayerMaxHealth` and store in `hl`
    add a, LOW(wPlayerMaxHealth)
    ld l, a
    adc a, HIGH(wPlayerMaxHealth)
    sub a, l
    ld h, a 
    ld c, [hl]
    sra c ; Each tile is 2 health, so divide by 2
    ld hl, vHeartBar
.topLoop

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-
    
    ld a, TILE_HEART_EMPTY
    ld [hli], a
    dec b
    jr z, .bottom
    dec c
    jr nz, .topLoop
    jr .drawHearts
.bottom
    dec c
    jr z, .drawHearts
    ld hl, vHeartBar + 32 ; Next row
.bottomLoop

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-
    
    ld a, TILE_HEART_EMPTY
    ld [hli], a
    dec c
    jr nz, .bottomLoop

.drawHearts
    ld a, e
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ; Add `a` to `wPlayerArray + Entity_Health` and store in `hl`
    add a, LOW(wPlayerArray + Entity_Health)
    ld l, a
    adc a, HIGH(wPlayerArray + Entity_Health)
    sub a, l
    ld h, a 
    ld b, [hl] ; save health for just a bit

    ld a, e ; make sure to store in the correct buffer
    ; Add `a` to `wHUDPlayerHealthBuffer` and store in `hl`
    add a, LOW(wHUDPlayerHealthBuffer)
    ld l, a
    adc a, HIGH(wHUDPlayerHealthBuffer)
    sub a, l
    ld h, a 
    ld [hl], b ; set health buffer to the current player's health
    ld a, b

    ; We need to clear carry before `rra`
    scf
    ccf

    rra ; This will set carry if A is odd, so we can draw a half-heart
    ld c, a
    jr nc, .setUp ; No half heart? run normally
    inc a ; since the half heart will be one tile further, we inc a
    cp a, 10
    ; These `-1`s are weird but they work so /shrug ?
    ld hl, vHeartBar - 1
    jr c, :+
    sub a, 10
    ld hl, vHeartBar + 32 - 1
    ; Add `a` to `hl`
:   add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, TILE_HEART_HALF
    ld [hld], a ; We already did a set up, so skip the regular one
    jr .bottomSetUp
.setUp
    ; Add `a` to `vHeartBar - 1` and store in `hl`
    add a, LOW(vHeartBar - 1)
    ld l, a
    adc a, HIGH(vHeartBar - 1)
    sub a, l
    ld h, a 
.bottomSetUp
    ld a, c
    and a, a
    jr z, .exit
    cp a, 10
    jr z, .heartTopReset ; If a == 10, reset pointer.
    jr c, .heartTopLoop ; If a < 10, only draw top row.
    sub a, 10
    ld b, a
    ; Add `a` to `vHeartBar + 32 - 1` and store in `hl`
    add a, LOW(vHeartBar + 32 - 1)
    ld l, a
    adc a, HIGH(vHeartBar + 32 - 1)
    sub a, l
    ld h, a 
.heartBottomLoop
    
:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ld a, TILE_HEART
    ld [hld], a
    dec b
    jr nz, .heartBottomLoop
.heartTopReset
    ld c, 10
    ld hl, vHeartBar + 10 - 1
.heartTopLoop

:   ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-
    
    ld a, TILE_HEART
    ld [hld], a
    dec c
    jr nz, .heartTopLoop
.exit
    ld a, [wActivePlayer]
    ld [wHUDActivePlayerBuffer], a

    ret

; Used to update and manage the printing function.
UpdatePrint::
    ld a, [wPrintState]
    and a, a
    ret z
    dec a
    jr z, .start
    dec a
    jr z, .initialClean
    dec a
    jr z, .scroll
    dec a
    jp z, .wait
    dec a
    jp z, .slideOut
    ld b, b
    ret

.start

    ld hl, vPrintBar - 32
    ld a, TILE_BLACK
    ld c, 32
    rst memset_small

    ; Clear the printing row.
    ld hl, vPrintBar
    ld a, TILE_TEXT_START
    ld c, 32
.startLoop
    ld [hli], a
    inc a
    dec c
    jr nz, .startLoop

    xor a, a
    ld [wHUDPrintIndex], a

    ld a, PRINT_STATE_INITIAL_CLEAN
    ld [wPrintState], a

    ret

.initialClean

    ld a, [wHUDPrintIndex]
    add a, a ; a * 2
    add a, a ; a * 4
    add a, a ; a * 8
    ld h, 0
    ld l, a
    add hl, hl
    ld bc, vTextTiles
    add hl, bc

    ld a, $FF
    ld c, 16 * 4
    rst memset_small

    ld a, [wHUDPrintIndex]
    add a, 4
    ld [wHUDPrintIndex], a
    cp a, 32
    ret nz

    xor a, a
    ld [wHUDPrintScroll], a
    ld a, SLIDE_IN_AMOUNT
    ld [wPrintWaitTimer], a
    ld a, CHARACTER_START_OFFSET ; skip some tiles
    ld [wHUDPrintIndex], a
    ld a, PRINT_STATE_SCROLL
    ld [wPrintState], a
    ret

.scroll

    ld hl, wPrintWaitTimer
    ld b, [hl]
    xor a, a
    cp a, b
    jr z, :+
    dec [hl]

:   ld a, STATIC_FX_PRINT_SCROLL
    ld [wStaticFX], a
    ld a, 144 - 32 - 1
    add a, b
    ldh [rLYC], a

    ld hl, wHUDPrintScroll
    ld a, [hl]
    inc [hl]

    ; Calculate whether to draw the next tile.
    scf
    ccf

    rra ; a/2
    ret c ; skip if there is a remainder
    rra ; a/4
    ret c ; skip if there is a remainder
    rra ; a/8
    ret c ; skip if there is a remainder

    call DrawCharacter
    inc c
    ret nz
    
    ; We hit a 0! Clean up!
    ld a, 32
    ld [wPrintWaitTimer], a
    ld a, PRINT_STATE_WAIT
    ld [wPrintState], a
    ret

.wait
    ld a, STATIC_FX_PRINT_SCROLL
    ld [wStaticFX], a
    ld a, 144 - 32 - 1
    ldh [rLYC], a

    ld hl, wHUDPrintScroll
    ld a, [hl]
    inc [hl]

    ; Calculate where to draw the next tile.
    scf
    ccf

    rra ; a/2
    ret c ; skip if there is a remainder
    rra ; a/4
    ret c ; skip if there is a remainder
    rra ; a/8
    ret c ; skip if there is a remainder

    ld hl, wHUDPrintIndex
    ld a, [hl]
    inc [hl]
    add a, a ; a * 2
    add a, a ; a * 4
    add a, a ; a * 8
    ld h, 0
    ld l, a
    add hl, hl
    ld bc, vTextTiles
    add hl, bc

    ld a, $FF
    ld c, 16
    rst memset_small

    ld a, [wPrintWaitTimer]
    dec a
    ld [wPrintWaitTimer], a
    ret nz

    ; We did all 32? disappear then

    xor a, a  
    ld [wPrintWaitTimer], a
    ld a, PRINT_STATE_SLIDE_OUT
    ld [wPrintState], a

    ret

.slideOut
    ld hl, wPrintWaitTimer
    ld b, [hl]
    ld a, SLIDE_IN_AMOUNT
    cp a, b
    jr z, :+
    inc [hl]

    ld a, STATIC_FX_PRINT_SCROLL
    ld [wStaticFX], a
    ld a, 144 - 32 - 1
    add a, b
    ldh [rLYC], a
    ret
:
    xor a, a
    ld [wPrintState], a
    ret

; Draws a character based on current pointers and indexes, and increments them accordingly
; Returns -1 in `c` if a "0" was reached.
DrawCharacter:
    ld hl, wHUDPrintIndex
    ld a, [hl]
    inc [hl]
    add a, a ; a * 2
    add a, a ; a * 4
    add a, a ; a * 8
    ld h, 0
    ld l, a
    add hl, hl
    ld bc, vTextTiles
    add hl, bc

    ld d, h
    ld e, l ; Current tile in de

    ld hl, wHUDPrintTarget
    ld a, [hli] ; bank
    ; Change this to a SwapBank when you move printing out of VBlank!
    ld [rROMB0], a ; rst SwapBank

    ld a, [hli] ; low
    ld h, [hl] ; high
    ld l, a
    inc hl
    ld a, l
    ld [wHUDPrintTarget + 1], a
    ld a, h
    ld [wHUDPrintTarget + 2], a
    dec hl
    ld a, [hl]

    ld c, -1
    and a, a
    ret z
    ; Special chars here!

    ld h, 0
    ld l, a
    ld bc, GameFont - ($20 * 8) ; We start on ascii character 32 (space), so we need to subtract 32 * 8 as an offset.
    add hl, hl ; a * 2
    add hl, hl ; a * 4
    add hl, hl ; a * 8
    add hl, bc
    ; hl now points to the tile we need to copy.
    ld c, 8

    ld a, BANK(GameFont)
    ld [rROMB0], a ; rst SwapBank

    jp Complement1bpp

; Disclaimer: This function is dumb and I just made it for fun :)
; @ a:  String Bank
; @ hl: String Pointer
PrintNotification::

    ld [wHUDPrintTarget], a ; load bank
    ld a, l
    ld [wHUDPrintTarget + 1], a
    ld a, h
    ld [wHUDPrintTarget + 2], a

    ld a, PRINT_STATE_START
    ld [wPrintState], a
    ret

TestPrintString::
    db "Hello World! --- "
    db "These messages can be arbitrarily long! "
    db "( As long as they fit in a single bank :P ) "
    db 0

SECTION "HUD Variables", WRAM0

wEnableHUD::
    ds 1

; The player that was active last time we updated the HUD, used for health bars
; Any value other than 0, 1, 2 is a reset.
wHUDActivePlayerBuffer:
    ds 1

wHUDPlayerHealthBuffer:
.octavia
    ds 1
.poppy
    ds 1
.tiber
    ds 1

wPrintState::
    ds 1

; Where is the print handler drawing from? (Bank, then LE pointer)
; This is incremented as chars draw, so serves as the index as well.
wHUDPrintTarget::
    ds 3 ; Bank, LE

; Which tile is next to draw?
wHUDPrintIndex:
    ds 1

; How far to scroll during HBlank?
wHUDPrintScroll::
    ds 1

; Wait 32 frames before hiding (could also be used for a pop in/out?)
wPrintWaitTimer:
    ds 1