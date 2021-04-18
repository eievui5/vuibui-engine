/* user_interface.asm
    Used for HUD and UI functions

*/

INCLUDE "include/engine.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/text.inc"
INCLUDE "include/tiles.inc"

DEF vHUD EQU $9F60
DEF vAHint EQU $9F80
DEF vBHint EQU $9F83
DEF vHeartBar EQU $9F66

SECTION "Stat Interrupt", ROM0[$48]
    ; Save register state
    push af
    jp Stat

SECTION "Heads Up Display", ROM0

ResetHUD::

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

    ld a, 144 - 16
    ldh [rWY], a
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

    ret

UpdateHUD::
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

    ld b, b

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

    ld b, b

    ret


Stat:

    ld a, SCREEN_HUD
    ldh [rLCDC], a
    ld a, 256 - (3*8) - 144
    ldh [rSCY], a
    xor a, a
    ldh [rSCX], a

    ; Restore register state
    pop af
    reti

SECTION "HUD Variables", WRAM0

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