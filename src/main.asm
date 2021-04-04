
INCLUDE "include/engine.inc"

SECTION "Header", ROM0[$100]
	di
	jp InitializeSystem
	ds $150 - $104, 0

SECTION "Main Loop", ROM0

; Split these up into an engine state jump table.
; Engine should only call out so that code can be reused.
Main::

.cleanOAM
    xor a ; ld a, 0
    ld bc, wShadowOAM.end - wShadowOAM
    ld hl, wShadowOAM
    call memset
    ldh [hOAMIndex], a ; Reset the OAM index.

    ; Check engine state
    ldh a, [hEngineState]
    and a, a
    ASSERT ENGINE_STATE_NORMAL == 0
    jr z, .handleNormal
    ASSERT ENGINE_STATE_SCRIPT == 1
    dec a
    jr z, .handleScript
    ASSERT ENGINE_STATE_ROOM_TRANSITION == 2

.handleTransition
    call RenderPlayersTransition
    call PlayerTransitionMovement
    jr .end

.handleScript
    call RenderEntities
    call HandleScript
    jr .end

.handleNormal
.entities
    call HandleEntities
    call PlayerCameraInterpolation ; Update camera!

    call RenderEntities

.end::
    ; When main is unhalted we ensure that it will not loop.
    xor a, a
    ld [wNewFrame], a
    halt
    ld a, [wNewFrame]
    and a, a
    jr z, .end
    xor a, a
    ld [wNewFrame], a
    jr Main

SECTION "Main Vars", WRAM0

; if != 0, restart main loop
wNewFrame::
    ds 1

SECTION "Engine Flags", HRAM
hEngineState::
    ds 1 

; The system we're running on. See engine.inc for constants.
; @ 0: DMG
; @ 1: CGB
; @ 2: AGB
hSystem::
    ds 1

; Stack Allocation
DEF STACK_SIZE EQU 32 * 2
SECTION "Stack", WRAMX[$E000 - STACK_SIZE]
    ds STACK_SIZE
wStackOrigin::
