
INCLUDE "include/graphics.inc"
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

SECTION "User Interface", ROMX

pb16_Heart::
    INCBIN "res/gfx/ui/heart.pb16"

pb16_MenuSeperators::
    INCBIN "res/gfx/ui/menu_seperators.pb16"

obpp_Pointer::
    INCBIN "res/gfx/ui/pointer.1bpp"

obpp_ItemSelection::
    INCBIN "res/gfx/ui/item_selection.h.1bpp"

SECTION "Color Palettes", ROMX
PalOctavia::
    pal 31, 31, 31, \
        18, 26, 24, \
         5,  7, 16, \
         0,  0,  0
PalPoppy::
    rgb 31, 31, 31
    rgb 19, 26, 18
    rgb  8, 18,  5
    rgb  0,  0,  0
PalTiber::
    rgb 31, 31, 31
    rgb 25, 21, 16
    rgb 19,  4,  4
    rgb  0,  0,  0
PalHurt::
    rgb  0,  0,  0
    rgb 31, 31, 31
    rgb 31,  0,  0
    rgb 31, 31,  0

PalGrey::
    rgb 31, 31, 31
    rgb 20, 20, 20
    rgb  9,  9,  9
    rgb  0,  0,  0

SECTION "Font", ROMX
GameFont::
    INCBIN "res/gfx/font/font.1bpp"