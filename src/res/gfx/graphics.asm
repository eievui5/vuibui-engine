
INCLUDE "include/players.inc"

SECTION "Player Graphics", ROMX
GfxOctavia:: 
    INCBIN "res/gfx/chars/octavia.h.2bpp"
.end::
GfxPoppy::
    INCBIN "res/gfx/chars/poppy.h.2bpp"
.end::
GfxTiber::
    INCBIN "res/gfx/chars/tiber.h.2bpp"
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
    INCBIN "res/gfx/misc/arrow.h.pb16"
.end::

SECTION "Font", ROMX
GameFont::
    INCBIN "res/gfx/font/font.2bpp"