
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

SECTION "Beach Panorama", ROMX
    BeachPanorama::
        ; DMG
        db 22 ; no of tiles
        dw pb16_DMGBeachPanoramaTiles
        dw BeachPanoramaMap
        ; CGB
        db 22 ; no of tiles
        dw pb16_CGBBeachPanoramaTiles
        dw BeachPanoramaMap
        dw BeachPanoramaAttributes
        dw BeachPanoramaPalettes
    pb16_DMGBeachPanoramaTiles::
        INCBIN "res/gfx/panorama/dmg_beach_tiles.pb16"
    pb16_CGBBeachPanoramaTiles::
        INCBIN "res/gfx/panorama/cgb_beach_tiles.pb16"
    BeachPanoramaMap::
        INCBIN "res/gfx/panorama/beach_map.tilemap"
    BeachPanoramaAttributes::
        INCBIN "res/gfx/panorama/beach_map.attrmap"
    BeachPanoramaPalettes::
        pal 31, 31, 31, \
            16, 16, 31, \
             0,  0,  0, \
             0,  0, 31
        pal 20, 20,  6, \
            31, 31, 10, \
            10, 10,  5, \
             0,  0, 31
        pal  8, 18,  5, \
            16, 16, 31, \
             4,  9,  5, \
             0,  0,  0
        pal 12, 12,  0, \
            10, 10,  0, \
             4,  9,  5, \
             6,  6,  0
        pal  8, 18,  5, \
             8, 18,  5, \
             4,  9,  5, \
             2,  4,  3
        pal_blank

SECTION "Font", ROMX
    GameFont::
        INCBIN "res/gfx/font/font.1bpp"

SECTION "Player Palettes", ROMX
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
