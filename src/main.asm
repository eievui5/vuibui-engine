INCLUDE "engine.inc"

SECTION "Null Handler", ROM0[$0000]
    nop
    nop
    rst CrashHandler

; @ TODO: Make a proper crash handler.
SECTION "Crash Handler", ROM0[$0038]
CrashHandler::

SECTION "Main Loop", ROM0

; Split these up into an engine state jump table.
; Engine should only call out so that code can be reused.
Main::

    ; Check if a script is currently running
    ld hl, wActiveScriptPointer + 1
    ld a, [hli]
    or a, [hl]
    call nz, HandleScript

    ; Check engine state
    ldh a, [hEngineState]
    ASSERT ENGINE_STATE_GAMEPLAY == 0
    and a, a
    jr z, Gameplay
    ASSERT ENGINE_STATE_ROOM_TRANSITION == 1
    dec a
    jr z, Transition
    ASSERT ENGINE_STATE_MENU == 2
    dec a
    jr z, Menu
    rst CrashHandler

.end::
    xor a, a
    ld [wNewFrame], a
    ; When main is unhalted we ensure that it will not loop.
    halt
    ld a, [wNewFrame]
    and a, a
    jr z, .end
    jr Main

Gameplay:

    ; Check if we're paused.
    ldh a, [hPaused]
    and a, a
    jr nz, .pauseMode

    ; Check if the player has pressed start.
    ldh a, [hCurrentKeys]
    bit PADB_START, a
    jr z, .skipInventoryOpen
    ld b, BANK("Inventory")
    ld de, InventoryHeader
    call AddMenu
    ld a, ENGINE_STATE_MENU
    ldh [hEngineState], a
    jr Menu
.skipInventoryOpen
    call HandleEntities
    call DetectCollectables
.pauseMode
    call CleanOAM
    ; Update the camera before rendering
    call PlayerCameraInterpolation
    call RenderEntities
    call RenderCollectables
    call UpdateHUD
    jr Main.end

Transition:
    call PlayerTransitionMovement
    call CleanOAM
    call RenderPlayersTransition
    jr Main.end

Menu:
    call ProcessMenus
    jr Main.end

SECTION "Main Vars", WRAM0

; if != 0, restart main loop
wNewFrame::
    DS 1

; Used by menus to manipulate hSCBuffer without changing the gameplay camera.
wGameplayScrollBuffer::
    .x  DS 1
    .y  DS 1

SECTION "Engine Flags", HRAM
hEngineState::
    DS 1

hPaused::
    DS 1

; The system we're running on. See engine.inc for constants.
; @ 0: DMG
; @ 1: CGB
; @ 2: AGB
hSystem::
    DS 1

; Stack Allocation
DEF STACK_SIZE EQU 32 * 2
SECTION "Stack", WRAM0[$E000 - STACK_SIZE]
    DS STACK_SIZE
wStackOrigin::
