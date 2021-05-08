INCLUDE "include/engine.inc"

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
    ASSERT ENGINE_STATE_GAMEPLAY == 0
    and a, a
    jr z, Gameplay
    ASSERT ENGINE_STATE_SCRIPT == 1
    dec a
    jr z, Script
    ASSERT ENGINE_STATE_ROOM_TRANSITION == 2
    dec a
    jr z, Transition
    ASSERT ENGINE_STATE_MENU == 3
    dec a
    jr z, Menu
    ld b, b

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

Gameplay:
    call HandleEntities
    ; Update the camera before rendering
    call PlayerCameraInterpolation
    call RenderEntities
    jr Main.end

Transition:
    call RenderPlayersTransition
    call PlayerTransitionMovement
    jr Main.end

Script:
    call RenderEntities
    call HandleScript
    jr Main.end

Menu:
    call ProcessMenus
    jr Main.end

SECTION "Main Vars", WRAM0

; if != 0, restart main loop
wNewFrame::
    ds 1

; Used by menus to manipulate hSCBuffer without changing the gameplay camera.
wGameplayScrollBuffer::
    .x  ds 1
    .y  ds 1

SECTION "Engine Flags", HRAM
hEngineState::
    ds 1 

; The system we're running on. See engine.inc for constants.
; @ 0: DMG
; @ 1: CGB
; @ 2: AGB
hSystem::
    ds 1

hCurrentBank::
    ds 1

; Stack Allocation
DEF STACK_SIZE EQU 32 * 2
SECTION "Stack", WRAMX[$E000 - STACK_SIZE]
    ds STACK_SIZE
wStackOrigin::
