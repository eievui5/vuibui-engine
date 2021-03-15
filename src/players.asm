
INCLUDE "include/directions.inc"
INCLUDE "include/enum.inc"
INCLUDE "include/entities.inc"
INCLUDE "include/graphics.inc"
INCLUDE "include/hardware.inc"
INCLUDE "include/items.inc"
INCLUDE "include/players.inc"
INCLUDE "include/switch.inc"

; States

    start_enum PLAYER_STATE
        enum NORMAL
        enum HURT
        enum FIRE_WAND
    end_enum

; Timer constants
KNOCK_FRAMES EQU 15
INVINCIBLE_FRAMES EQU 60

; Frame Index offsets (distance from start to X)
STEP_OFFSET EQU 4
SWING_OFFSET EQU 8

SECTION "Player AI", ROMX

OctaviaPlayerLogic::
    ; Always start by offsetting frame by facing direction
    ld a, [wOctavia_Direction]
    ld [wOctavia_Frame], a

    ; Check for damage
    ld a, [wOctavia_InvTimer] ; Check the timer...
    and a, a ; If the inv timer is running, no damage!
    jr z, .acceptDamage
    ; If we're here and not accepting damage, set it to 0
    xor a, a
    ld [wOctavia_CollisionData], a
    ld a, [wOctavia_InvTimer]
    jr .decTimer
.acceptDamage
    ld a, [wOctavia_CollisionData] ; Load the collision data
    and a, a
    jr z, .noDamage
    ld a, PLAYER_STATE_HURT
    ld [wOctavia_State], a 
    ld a, KNOCK_FRAMES
    ld [wOctavia_Timer], a
    ; Next, set the timer. This falls through.
    ld a, INVINCIBLE_FRAMES + 1
.decTimer
    dec a
    ld [wOctavia_InvTimer], a
.noDamage

    ; Is this the active player?
    ld a, [wActivePlayer]
    ASSERT PLAYER_OCTAVIA == 0
    and a, a
    ret nz ; For now, skip processing if the entity is not active.
.activeControl
    ld a, [wOctavia_State]
    switch
    case PLAYER_STATE_NORMAL, OctaviaActiveNormal
    case PLAYER_STATE_HURT, OctaviaDamage
    case PLAYER_STATE_FIRE_WAND, OctaviaFireRod
    end_switch

; TODO: Make modular and place in a fuction.
OctaviaActiveNormal: ; How to move.
    ; Attack check
    ld a, [wOctaviaEquipped]
    ld b, a
    ld hl, wOctavia_State
    call UseItemCheck
.activeMove

    ; Reset velocity if we have control over movement
    xor a, a
    ld [wOctavia_YVel], a
    ld [wOctavia_XVel], a
    ; Are we even moving right now?
    ldh a, [hCurrentKeys]
    and a, $F0
    jr z, .activeMoveAndSlide ; Let's not do anything if not. (Still move though!)
    ; Every 32th tick (~ 1/2 second)...
    ld a, [wOctavia_Timer]
    inc a 
    ld [wOctavia_Timer], a
    bit 4, a 
    jr z, .activeMoveDown
    ; ...Offset to step animation
    ld a, [wOctavia_Frame]
    add a, STEP_OFFSET
    ld [wOctavia_Frame], a
.activeMoveDown
    ldh a, [hCurrentKeys]
    bit PADB_DOWN, a
    jr z, .activeMoveUp
    ld a, 1
    ld [wOctavia_YVel], a
    ; Update facing
    ASSERT DIR_DOWN == 0
    xor a, a
    ld [wOctavia_Direction], a
    ; Restore a
    ldh a, [hCurrentKeys] 
    ; Down and Up cannot be pressed, so skip to Left
    jr .activeMoveLeft
.activeMoveUp
    bit PADB_UP, a
    jr z, .activeMoveLeft
    ld a, -1
    ld [wOctavia_YVel], a
    ; Update facing
    ld a, DIR_UP
    ld [wOctavia_Direction], a
    ; Restore a
    ldh a, [hCurrentKeys] 
.activeMoveLeft
    bit PADB_LEFT, a
    jr z, .activeMoveRight
    ld a, -1
    ld [wOctavia_XVel], a
    ; Update facing
    ld a, DIR_LEFT
    ld [wOctavia_Direction], a
    ; Don't bother restoring a
    ; Left and Right cannot be pressed, so skip to Render
    jr .activeMoveAndSlide
.activeMoveRight
    bit PADB_RIGHT, a
    jr z, .activeMoveAndSlide
    ld a, 1
    ld [wOctavia_XVel], a
    ld a, DIR_RIGHT
    ld [wOctavia_Direction], a
    ; Don't bother restoring a
.activeMoveAndSlide
    ld hl, wOctavia
    call MoveAndSlide
.activeScroll
    ; Scroll
    ld a, [wOctavia_YPos]
    sub a, 80 + 8
    ld e, a
    ld a, [wOctavia_XPos]
    sub a, 72 + 8
    ld d, a
    jp SetScrollBuffer
    ret

OctaviaDamage:
    ld a, [wOctavia_CollisionData]
    and a, $0F
    jr z, .timer ; No damage left? skip...
    ld b, a
    xor a, a
    ld [wOctavia_CollisionData], a
    ld a, [wOctavia_Health]
    sub a, b
    jr nc, .storeHealth ; If damage < health, we're not dead!
    xor a, a
    ; Death Stuff Here.
.storeHealth
    ld [wOctavia_Health], a
.timer
    ld a, [wOctavia_Timer]
    dec a
    ld [wOctavia_Timer], a
    jr nz, .knockback
    ASSERT PLAYER_STATE_NORMAL == 0
    ; if we're down here, a already = 0
    ld [wOctavia_State], a
.knockback
    ld hl, wOctavia
    call MoveAndSlide
.damageScroll
    ; Scroll
    ld a, [wOctavia_YPos]
    sub a, 80 + 8
    ld e, a
    ld a, [wOctavia_XPos]
    sub a, 72 + 8
    ld d, a
    jp SetScrollBuffer
    ret

OctaviaFireRod:
    ld a, [wOctavia_Flags]
    and a, a
    jr nz, .skipInit ; Are the flags == 0? initiallize!
    ld [wOctavia_Timer], a
    inc a
    ld [wOctavia_Flags], a
.skipInit
    ld a, [wOctavia_Timer]
    inc a
    ld [wOctavia_Timer], a
    cp a, 4 + 1 ; 4 frame delay...
    ret c
    ld a, [wOctavia_Frame]
    add a, SWING_OFFSET
    ld [wOctavia_Frame], a
    ld a, [wOctavia_Timer]
    cp a, 8 + 4 + 1 ; 8 frame action!
    ret c
    ASSERT PLAYER_STATE_NORMAL == 0
    ld a, [wOctavia_YPos]
    ld c, a
    ld a, [wOctavia_XPos]
    ld b, a
    ld de, PlayerSpell
    call SpawnEntity
    xor a, a
    ld [wOctavia_State], a
    ld a, [wOctavia_Direction]
    push hl
    switch
    case 0, .down
    case 1, .up
    case 2, .right
    case 3, .left 
    end_switch
.down
    pop hl
    ld a, 3
    ld [hl], a
    ret
.up
    pop hl
    ld a, -3
    ld [hl], a
    ret
.right
    pop hl
    inc l
    ld a, 3
    ld [hl], a
    ret
.left
    pop hl
    inc l
    ld a, -3
    ld [hl], a
    ret

; Has the player used an item? Which one?
; @ b:  Value of wPlayerEquipped
; @ hl: Pointer to wPlayerState (preserved)
UseItemCheck::
.aCheck
    ldh a, [hNewKeys]
    bit PADB_A, a
    jr z, .bCheck
    ; First check for generic interaction
    ; Now for items!
    ld a, b
    and a, $0F ; Check if A item exists... (and mask out B)
    jr nz, .loadItemState
    ret ; Nothing there? get out of here!
.bCheck
    ldh a, [hNewKeys]
    bit PADB_B, a
    ret z
    ld a, b
    swap a ; Swap around to B item
    and a, $0F ; Check if B item exists... (and mask out A)
    ret z ; Nothing there? get out of here!
.loadItemState ; Queue up the item state to run next frame
    ld de, ItemStateLoopup - 1
    add_r16_a d, e
    dec l
    xor a, a
    ld [hli], a ; Reset flags so that item states can initiallize.
    ld a, [de] ; Load state based off item ID
    ld [hl], a
    ret

; Used to convert the 4-bit item enum into the player states
ItemStateLoopup::
    ; The first item for each character should correspond to the same state!
    ; Eg, Sword state = 2, Wand state = 2
    ASSERT ITEM_FIRE_WAND == 1
    db PLAYER_STATE_FIRE_WAND

; TODO: MOVE THESE!

; Octavia
OctaviaMetasprites::
; Still
.down       dw .spriteDown
.up         dw .spriteUp
.right      dw .spriteRight
.left       dw .spriteLeft
; Step
.downStep   dw .spriteDownStep
.upStep     dw .spriteUpStep
.rightStep  dw .spriteRightStep
.leftStep   dw .spriteLeftStep
; Swing
.downSwing  dw .spriteDownSwing
.upSwing    dw .spriteUpSwing
.rightSwing dw .spriteRightSwing
.leftSwing  dw .spriteLeftSwing
; Grab
.downGrab  dw .spriteDownGrab
.upGrab    dw .spriteUpGrab
.rightGrab dw .spriteRightSwing ; Side swing and 
.leftGrab  dw .spriteLeftSwing ; grab are the same

.spriteDown:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteUp:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteRight:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteLeft: ; Flipped version of .spriteRight
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END

; Steps

.spriteDownStep: ; Flipped version
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END


.spriteUpStep: ; Flipped version
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END


.spriteRightStep:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_STEP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_STEP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteLeftStep: ; Flipped version of .spriteRight
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_STEP_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_STEP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END

; Swings

.spriteDownSwing:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_2 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END

.spriteUpSwing:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteRightSwing:
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END


.spriteLeftSwing: ; Flipped version of .spriteRight
    db -8 ; y
    db -8 ; x
    db OCTAVIA_RIGHT_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_RIGHT_1 ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END

.spriteDownGrab
    db -8 ; y
    db -8 ; x
    db OCTAVIA_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_DOWN_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db METASPRITE_END

.spriteUpGrab
    db -8 ; y
    db -8 ; x
    db OCTAVIA_UP_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 | OAMF_XFLIP ; Flags

    db -8 ; y
    db 0 ; x
    db OCTAVIA_UP_ACT ; Tile ID
    db OAMF_PAL0 | OAMF_BANK0 ; Flags

    db METASPRITE_END

SECTION "Player Variables", WRAM0

; The Character currently being controlled by the player. Used as an offset.
wActivePlayer::
    ds 1

; The currently equipped items.
; Lower Nibble = A, Upper Nibble = B
wOctaviaEquipped:: 
    ds 1
; The currently equipped items.
; Lower Nibble = A, Upper Nibble = B
wPoppyEquipped::
    ds 1
; The currently equipped items.
; Lower Nibble = A, Upper Nibble = B
wTiberEquipped::
    ds 1

SECTION "Player Array", WRAM0, ALIGN[$08]
wPlayerArray::
    dstruct Entity, wOctavia
    dstruct Entity, wPoppy

    dstructs 2, Entity, wOctaviaProjectiles
    dstructs 2, Entity, wPoppyProjectiles