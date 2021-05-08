        IF !DEF(MENU_INC)
DEF MENU_INC EQU 1

INCLUDE "include/enum.inc"
INCLUDE "include/structs.inc"

DEF MENU_STACK_CAPACITY equ 10

; When an event is called, the struct can be accessed with:
; ld hl, sp+2
; ld a, [hli]
; ld h, [hl]
; ld l, a
; This points to: 
;   - RedrawFunc:   RedrawFunc + 1 (must inc or dec)
;   - ButtonHooks:  AllowWrapping
;   - Closing:      

    struct Menu
        bytes 1, Bank ; ROM bank where everything is located
        words 1, InitFunc
        bytes 1, ButtonMask ; Mask applied to hPressedButtons and hHeldButtons
        bytes 1, EnableRepeatPress ; Set to non-zero to make direction buttons auto-repeat (hold for more than half a second to press every other frame)
        words 8, ButtonHooks ; Pointers to functions to be run each time a button is pressed
        bytes 1, PrevSelectedItem ; Item selected on previous frame
        bytes 1, AllowWrapping ; Bit 0 non-zero to allow wrapping. NOTE: could be used for other flags, too
        bytes 1, SelectedItem ; Holds the default selected item in ROM, then is modified in RAM
        bytes 1, Size ; Number of items in the menu
        words 1, RedrawFunc ; Function called on every frame after buttons have been processed
        words 1, ItemsPtr ; Pointer where the menu's items are located (might be anything, that's left for the redraw function to decide)
        words 1, ClosingFunc ; Function to be called when the menu is closed

        dunion ROMSize ; Number of bytes to copy. Replaced by RepeatPressCounter when in RAM.
        ; Work memory, not stored in ROM
        bytes 1, RepeatPressCounter ; Tracks for how many frames RepeatPress has been in effect (loops between 30 and 31, though) Every time the counter hits 32, it's reset to 31 and the button is "pressed"
        bytes 2, MiscState ; The struct is allowed to do anything with this (frame counter, state, etc.)
    end_struct


    ; Menu actions
    start_enum MENU
        enum ACTION_NONE
        ; These are each button's default action
        enum ACTION_MOVE_DOWN
        enum ACTION_MOVE_UP
        enum ACTION_MOVE_LEFT
        enum ACTION_MOVE_RIGHT
        enum ACTION_NONE_START ; Placeholder since START shouldn't do anything
        enum ACTION_NONE_SELECT
        enum ACTION_CANCEL
        enum ACTION_VALIDATE
        ; These can only be triggered manually
        enum ACTION_NEW_MENU ; Followed by a 3-byte pointer to the menu
        enum ACTION_INVALID ; Any action greater than this is invalid, and does nothing
    end_enum

    ; Menu closing reasons
    start_enum MENU
        enum NOT_CLOSED
        enum CANCELLED
        enum VALIDATED
    enum

    ENDC