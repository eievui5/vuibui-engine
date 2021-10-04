
INCLUDE "graphics.inc"

SECTION "Dialogue Gradients", ROMX

GradientPink::
    FOR i, 20
        rgb 31-(i/2), i/2, 31-((31-i)/2)
    ENDR

GradientRainbow::
    rgb 0, 0, 0
    FOR i, 4
        rgb 21, (i*6), 0
    ENDR
    FOR i, 1, 3
        rgb 21-(i*6), 21, 0
    ENDR
    FOR i, 4
        rgb 0, 21, (i*6)
    ENDR
    FOR i, 1, 3
        rgb 0, 21-(i*6), 21
    ENDR
    FOR i, 4
        rgb (i*6), 0, 21
    ENDR
    FOR i, 1, 3
        rgb 21, 0, 21-(i*6)
    ENDR
    rgb 21, 0, 0

GradientGreen::
    FOR i, 10
        rgb (i+1)/2, 25-(10-i), i/2
    ENDR
    FOR i, 10
        rgb (10-(i+1))/2, 25-i, (10-i)/2
    ENDR

GradientBlue::
    FOR i, 10
        rgb (i+1)/2, i/2, 25-(10-i)
    ENDR
    FOR i, 10
        rgb (10-(i+1))/2, (10-i)/2, 25-i
    ENDR

GradientRed::
    FOR i, 10
        rgb 31-(10-i), (i+1)/2, i/2
    ENDR
    FOR i, 10
        rgb 31-i, (10-(i+1))/2, (10-i)/2
    ENDR