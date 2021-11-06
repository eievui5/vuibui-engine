
INCLUDE "graphics.inc"
INCLUDE "players.inc"

SECTION "Player Graphics", ROMX
GfxOctavia:: INCBIN "res/gfx/chars/octavia.h.2bpp"
.end::
GfxPoppy:: INCBIN "res/gfx/chars/poppy.h.2bpp"
.end::
GfxTiber:: INCBIN "res/gfx/chars/tiber.h.2bpp"
.end::
GfxArrow:: INCBIN "res/gfx/misc/arrow.h.2bpp"
.end::
GfxSword:: INCBIN "res/gfx/misc/sword.h.2bpp"
.end::
GfxSparkle:: INCBIN "res/gfx/misc/sparkle.h.2bpp"
.end::

SECTION "User Interface", ROMX
GfxHeart:: INCBIN "res/gfx/ui/heart.2bpp"
.end::
GfxMenuSeperators:: INCBIN "res/gfx/ui/menu_seperators.2bpp"
.end::
obpp_Pointer:: INCBIN "res/gfx/ui/pointer.1bpp"
.end::
obpp_ItemSelection:: INCBIN "res/gfx/ui/item_selection.h.1bpp"
.end::
GfxButtons:: INCBIN "res/gfx/font/buttons.2bpp"
.end::

SECTION "Item Icons", ROMX
GfxPlayerItems::
    GfxOctaviaItems::
        GfxFireSpell:: INCBIN "res/gfx/ui/items/fire_spell.2bpp"
        GfxIceSpell:: INCBIN "res/gfx/ui/items/ice_spell.2bpp"
        GfxShockSpell:: INCBIN "res/gfx/ui/items/shock_spell.2bpp"
        GfxHealSpell:: INCBIN "res/gfx/ui/items/heal_spell.2bpp"
    GfxPoppyItems::
        GfxBow:: INCBIN "res/gfx/ui/items/bow.2bpp"
        GfxKnife:: INCBIN "res/gfx/ui/items/knife.2bpp"
        GfxCloak:: INCBIN "res/gfx/ui/items/cloak.2bpp"
        GfxPlaceholder:: INCBIN "res/gfx/ui/items/placeholder.2bpp"
    GfxTiberItems::
        GfxSwordIcon:: INCBIN "res/gfx/ui/items/sword.2bpp"
        GfxShield:: INCBIN "res/gfx/ui/items/shield.2bpp"
        GfxHammer:: INCBIN "res/gfx/ui/items/hammer.2bpp"
        GfxGlove:: INCBIN "res/gfx/ui/items/glove.2bpp"

SECTION "Font", ROMX
GameFont:: INCBIN "res/gfx/font/font.1bpp"

SECTION "Player Palettes", ROMX

PalPlayers::
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
