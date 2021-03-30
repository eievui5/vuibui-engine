
INCLUDE "include/players.inc"

SECTION "Player Graphics", ROMX
; Octavia's Frames
GfxOctaviaMain:: 
    INCBIN "gfx/octavia/octavia_main.2bpp"
.end::

GfxPlayerSpells::
    ASSERT SPELL_GFX_FIRE == 1
.fire::
    INCBIN "gfx/spells/fire.2bpp"
.fireEnd::
    ASSERT SPELL_GFX_ICE == 2
.ice::
    INCBIN "gfx/spells/ice.2bpp"
.iceEnd::

SECTION "Font", ROMX
GameFont::
    INCBIN "gfx/font.2bpp"