
INCLUDE "include/players.inc"

SECTION "Player Graphics", ROMX
; Octavia's Frames
GfxOctavia:: 
    INCBIN "res/gfx/chars/octavia.2bpp"
.end::

GfxPlayerSpells::
    ASSERT SPELL_GFX_FIRE == 1
    INCBIN "res/gfx/misc/fire.2bpp"
    ASSERT SPELL_GFX_ICE == 2
    INCBIN "res/gfx/misc/ice.2bpp"
    ASSERT SPELL_GFX_SHOCK == 3
    INCBIN "res/gfx/misc/shock.2bpp"
    ASSERT SPELL_GFX_HEAL == 4
    INCBIN "res/gfx/misc/heal.2bpp"

pb16_GfxArrow::
    INCBIN "res/gfx/misc/arrow.pb16"
.end::

SECTION "Font", ROMX
GameFont::
    INCBIN "res/gfx/font/font.2bpp"