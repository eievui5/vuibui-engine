INCLUDE "include/banks.inc"
INCLUDE "include/entity.inc"
INCLUDE "include/entity_script.inc"
INCLUDE "include/graphics.inc"

SECTION "Death Particle Definition", ROM0

DeathParticle::
    far_pointer DeathParticleLogic
    far_pointer DeathParticleMetasprites
    far_pointer RenderMetasprite.native

SECTION "Death Particle Logic", ROM0

DeathParticleLogic:
    call HandleEntityScript
    ret

DeathParticleScript::
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
    
DeathParticleMetasprites:
    dw .start
    dw .alt
    dw .single

.start
    db -16, -16, TILE_SPARKLE_LEFT, 2
    db -16, -8, TILE_SPARKLE_RIGHT, 2
    db 0, 0, TILE_SPARKLE_LEFT, 2
    db 0, 8, TILE_SPARKLE_RIGHT, 2
    db METASPRITE_END

.alt
    db 0, -16, TILE_SPARKLE_LEFT, 2
    db 0, -8, TILE_SPARKLE_RIGHT, 2
    db -16, 0, TILE_SPARKLE_LEFT, 2
    db -16, 8, TILE_SPARKLE_RIGHT, 2
    db METASPRITE_END

.single
    db -8, -8, TILE_SPARKLE_LEFT, 2
    db -8, 0, TILE_SPARKLE_RIGHT, 2
    db METASPRITE_END