/* user_interface.asm
    Used for HUD and UI functions

*/

INCLUDE "include/engine.inc"
INCLUDE "include/entities.inc"
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
    ld a, 144 - 16
    ldh [rWY], a
    ldh [rLYC], a
    ld a, TILE_WHITE

    ; Clear the HUD
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
    ld b, b
    ld hl, wPlayerArray + Entity_Health
    ASSERT sizeof_Entity == 16
    swap a ; a * 16
    add_r16_a hl
    ld a, [hl]

.redraw
    ld e, a ; save active player
    ld b, b
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
    ld a, [hl]
    rra ; This will set carry if A is odd, so we can draw a half-heart
    ld c, a
    jr nc, .setUp ; No half heart? run normally
    inc a ; since the half heart will be one tile further, we inc a
    ld b,b 
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
    add_r16_a hl
.bottomSetUp
    ld b, b
    ld a, c
    cp a, 10
    jr z, .heartTopReset ; If a == 10, reset pointer.
    jr c, .heartTopLoop ; If a < 10, only draw top row.
    sub a, 10
    ld b, a
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
    ld a, [wActivePlayer]
    ld [wHUDActivePlayerBuffer], a
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