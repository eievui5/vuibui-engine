
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
    .shock::
        ASSERT SPELL_GFX_SHOCK == 3
        INCBIN "gfx/spells/shock.2bpp"
    .shockEnd::
    .heal::
        ASSERT SPELL_GFX_HEAL == 4
        INCBIN "gfx/spells/heal.2bpp"
    .healEnd::

GfxArrow::
    INCBIN "gfx/misc/arrow.2bpp"

SECTION "Font", ROMX
GameFont::
    INCBIN "gfx/misc/font.2bpp"