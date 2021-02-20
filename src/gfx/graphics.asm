
    IF !DEF(GRAPHICS_ASM)
GRAPHICS_ASM SET 1

SECTION "Player Graphics", ROMX

; Octavia's Frames
GfxOctaviaMain:: 
    INCBIN "gfx/octavia/octavia_main.2bpp"
.end::

ENDC