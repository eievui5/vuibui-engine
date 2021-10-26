
INCLUDE "graphics.inc"
INCLUDE "players.inc"

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
    pb16_GfxArrow::
        INCBIN "res/gfx/misc/arrow.h.pb16"
    pb16_GfxSword::
        INCBIN "res/gfx/misc/sword.h.pb16"
    pb16_GfxSparkle::
        INCBIN "res/gfx/misc/sparkle.h.pb16"

SECTION "User Interface", ROMX
    pb16_Heart::
        INCBIN "res/gfx/ui/heart.pb16"
    pb16_MenuSeperators::
        INCBIN "res/gfx/ui/menu_seperators.pb16"
    obpp_Pointer::
        INCBIN "res/gfx/ui/pointer.1bpp"
    obpp_ItemSelection::
        INCBIN "res/gfx/ui/item_selection.h.1bpp"
    pb16_Buttons::
    INCBIN "res/gfx/font/buttons.pb16"

SECTION "Item Icons", ROMX
    GfxFireSpell::
        INCBIN "res/gfx/ui/items/fire_spell.2bpp"
    GfxIceSpell::
        INCBIN "res/gfx/ui/items/ice_spell.2bpp"
    GfxShockSpell::
        INCBIN "res/gfx/ui/items/shock_spell.2bpp"
    GfxHealSpell::
        INCBIN "res/gfx/ui/items/heal_spell.2bpp"
    GfxBow::
        INCBIN "res/gfx/ui/items/bow.2bpp"
    GfxKnife::
        INCBIN "res/gfx/ui/items/knife.2bpp"
    GfxCloak::
        INCBIN "res/gfx/ui/items/cloak.2bpp"
    GfxPlaceholder::
        INCBIN "res/gfx/ui/items/placeholder.2bpp"
    GfxSword::
        INCBIN "res/gfx/ui/items/sword.2bpp"
    GfxShield::
        INCBIN "res/gfx/ui/items/shield.2bpp"
    GfxHammer::
        INCBIN "res/gfx/ui/items/hammer.2bpp"
    GfxGlove::
        INCBIN "res/gfx/ui/items/glove.2bpp"

SECTION "Font", ROMX
    GameFont::
        INCBIN "res/gfx/font/font.1bpp"

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
