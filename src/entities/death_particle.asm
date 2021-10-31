INCLUDE "banks.inc"
INCLUDE "entity.inc"
INCLUDE "entity_script.inc"
INCLUDE "graphics.inc"

SECTION "Death Particle Definition", ROM0

DeathParticle::
    far_pointer DeathParticleLogic
    far_pointer DeathParticleMetasprites
    far_pointer RenderMetasprite.native

SECTION "Death Particle Logic", ROMX

DeathParticleLogic:
    jp HandleEntityScript

DeathParticleScript::
    new_script

    define_fields
    field COUNTER

    seta Entity_Frame, 0
    setf COUNTER, 6
    forf COUNTER
        yield
    endfor

    seta Entity_Frame, 1
    setf COUNTER, 6
    forf COUNTER
        yield
    endfor

    seta Entity_Frame, 2
    setf COUNTER, 10
    forf COUNTER
        yield
    endfor

    kill

    end_script

DeathParticleMetasprites:
    DW .start
    DW .alt
    DW .single

.start
    DB -16, -16, TILE_SPARKLE_LEFT, 2
    DB -16, -8, TILE_SPARKLE_RIGHT, 2
    DB 0, 0, TILE_SPARKLE_LEFT, 2
    DB 0, 8, TILE_SPARKLE_RIGHT, 2
    DB METASPRITE_END

.alt
    DB 0, -16, TILE_SPARKLE_LEFT, 2
    DB 0, -8, TILE_SPARKLE_RIGHT, 2
    DB -16, 0, TILE_SPARKLE_LEFT, 2
    DB -16, 8, TILE_SPARKLE_RIGHT, 2
    DB METASPRITE_END

.single
    DB -8, -8, TILE_SPARKLE_LEFT, 2
    DB -8, 0, TILE_SPARKLE_RIGHT, 2
    DB METASPRITE_END