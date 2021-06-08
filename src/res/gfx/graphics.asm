
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
    pb16_GfxArrow::
        INCBIN "res/gfx/misc/arrow.h.pb16"
    pb16_GfxSword::
        INCBIN "res/gfx/misc/sword.h.pb16"

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
    pb16_FireSpell::
        INCBIN "res/gfx/ui/items/fire_spell.pb16"
    pb16_IceSpell::
        INCBIN "res/gfx/ui/items/ice_spell.pb16"
    pb16_ShockSpell::
        INCBIN "res/gfx/ui/items/shock_spell.pb16"
    pb16_HealSpell::
        INCBIN "res/gfx/ui/items/heal_spell.pb16"
    pb16_Bow::
        INCBIN "res/gfx/ui/items/bow.pb16"
    pb16_Knife::
        INCBIN "res/gfx/ui/items/knife.pb16"
    pb16_Cloak::
        INCBIN "res/gfx/ui/items/cloak.pb16"
    pb16_Placeholder::
        INCBIN "res/gfx/ui/items/placeholder.pb16"
    pb16_Sword::
        INCBIN "res/gfx/ui/items/sword.pb16"
    pb16_Shield::
        INCBIN "res/gfx/ui/items/shield.pb16"
    pb16_Hammer::
        INCBIN "res/gfx/ui/items/hammer.pb16"
    pb16_Glove::
        INCBIN "res/gfx/ui/items/glove.pb16"

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
