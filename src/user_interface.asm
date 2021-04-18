/* user_interface.asm
    Used for HUD and UI functions

*/

INCLUDE "include/banks.inc"
INCLUDE "include/engine.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/stat.inc"
INCLUDE "include/text.inc"
INCLUDE "include/tiles.inc"

DEF vPrintBar EQU $9F40
DEF vHUD EQU $9F60
DEF vAHint EQU $9F80
DEF vBHint EQU $9F83
DEF vHeartBar EQU $9F66

DEF CHARACTER_START_OFFSET EQU 20 ; How many tiles to skip for intial draw?
DEF SLIDE_IN_AMOUNT EQU 15 ; How many pixels before we've slid in?

SECTION "Heads Up Display", ROM0

ResetHUD:

    ld a, 1
    ldh [rVBK], a
    ld a, OAMF_GBCPAL7
    ; Color the HUD
    ld bc, 20
    ld hl, vHUD
    call memset
    ld bc, 20
    ld hl, vHUD + 32
    call memset
    xor a, a
    ldh [rVBK], a

    ld a, STATIC_FX_SHOW_HUD
    ld [wStaticFX], a
    ld a, 144 - 16 - 1
    ldh [rLYC], a

    ; Clear the HUD
    ld a, TILE_WHITE
    ld bc, 20
    ld hl, vHUD
    call memset
    ld bc, 20
    ld hl, vHUD + 32
    call memset

    ; Load the button hints
    ld hl, vAHint
    ld a, TILE_A_CHAR
    ld [hl], a
    ASSERT HIGH(vAHint) == HIGH(vBHint)
    ld l, LOW(vBHint)
    ASSERT TILE_A_CHAR + 1 == TILE_B_CHAR
    inc a
    ld [hl], a

    ; Reset Button Graphics
    xor a, a
    ld hl, wHUDActiveItemGraphic
    ld [hli], a
    ld [hl], a

    ; Signal to reset healthbars
    ld a, -1
    ld [wHUDActivePlayerBuffer], a

    inc a
    ld [wHUDReset], a

    ret

UpdateHUD::

    ld a, [wHUDReset]
    and a, a
    jp nz, ResetHUD

    ld a, [wActivePlayer]

    ld hl, wHUDActivePlayerBuffer
    cp a, [hl]
    jr nz, .redraw ; If the active player has changed, just redraw everything.

    ; Only animate healthbar every 4th frame
    ld a, [wFrameTimer]
    bit 0, a
    ret z
    bit 1, a
    ret z

    ld a, [wActivePlayer]
    ; Get the active player's health
    ld hl, wPlayerArray + Entity_Health
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    add_r16_a hl
    ld b, [hl]
    ; Get the last value we checked for health
    ld a, [wActivePlayer]
    ld hl, wHUDPlayerHealthBuffer
    add_r16_a hl
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
    ld c , a
    ld a, TILE_HEART_EMPTY
    cp a, b
    ld a, c
    jr nz, :+
    inc a
:
    cp a, 10 + 1
    ; These `-1`s are weird but they work so /shrug ?
    ld hl, vHeartBar - 1
    jr c, .skipBottom
    sub a, 10 
    ld hl, vHeartBar + 32 - 1
.skipBottom
    add_r16_a hl
    ld [hl], b
    ret


.redraw

    ; Clear the HUD
    ld a, TILE_WHITE
    ld bc, 10
    ld hl, vHeartBar
    call memset
    ld bc, 10
    ld hl, vHeartBar + 32
    call memset

    ldh a, [hSystem]
    and a, a
    jr z, .skipColor
    ld hl, PalOctavia
    ASSERT PalOctavia + sizeof_PALETTE == PalPoppy && PalPoppy + sizeof_PALETTE == PalTiber
    ASSERT sizeof_PALETTE == 8
    ld a, [wActivePlayer]
    add a, a ; a * 2
    add a, a ; a * 4
    add a, a ; a * 8
    add_r16_a hl
    ld de, wBCPD + sizeof_PALETTE * 7
    ld c, sizeof_PALETTE
    call memcopy_small
    ld a, PALETTE_STATE_RESET
    ld [wPaletteState], a

.skipColor

    ld a, [wActivePlayer]
    ld e, a ; save for later!

    ; Reset Health Bar (max health)
    ld b, 10
    ld hl, wPlayerMaxHealth
    add_r16_a hl
    ld c, [hl]
    sra c ; Each tile is 2 health, so divide by 2
    ld a, TILE_HEART_EMPTY
    ld hl, vHeartBar
.topLoop
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
    ld [hli], a
    dec c
    jr nz, .bottomLoop

.drawHearts
    ld a, e
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    ld hl, wPlayerArray + Entity_Health
    add_r16_a hl
    ld b, [hl] ; save health for just a bit

    ld a, e ; make sure to store in the correct buffer
    ld hl, wHUDPlayerHealthBuffer
    add_r16_a hl
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
:   add_r16_a hl
    ld a, TILE_HEART_HALF
    ld [hld], a ; We already did a set up, so skip the regular one
    jr .bottomSetUp
.setUp
    ld hl, vHeartBar - 1
    add_r16_a hl
.bottomSetUp
    ld a, c
    and a, a
    jr z, .exit
    cp a, 10
    jr z, .heartTopReset ; If a == 10, reset pointer.
    jr c, .heartTopLoop ; If a < 10, only draw top row.
    sub a, 10
    ld b, a
    ld hl, vHeartBar + 32 - 1
    add_r16_a hl
    ld a, TILE_HEART
.heartBottomLoop
    ld [hld], a
    dec b
    jr nz, .heartBottomLoop
.heartTopReset
    ld c, 10
    ld hl, vHeartBar + 10 - 1
.heartTopLoop
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
    ld bc, 32
    call memset

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
    ld bc, 16 * 4
    call memset

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
    ld bc, 16
    call memset

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
    swap_bank

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
    swap_bank

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
    db "These messages can be arbitrarily long! ( As long as they fit in a single bank :P ) "
    db 0

SECTION "HUD Variables", WRAM0

wHUDReset::
    ds 1

wHUDActiveItemGraphic:
.slotA
    ds 1
.slotB
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