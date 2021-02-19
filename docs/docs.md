# Info

- Todo

# Main

## Initiallization

- Configures interrupts
- Clears memory
- Copies the OAM routine.

## Loop

- Starts by clearing the OAM index, to ensure that all sprites are placed in an open area of OAM.
- Loops through `wEntityArray`, which contains information on each living entity, as well as a script which processes and renders the entity
    - See [The Entity Array](#the-entity-array)
- Ends by halting to save power, waiting for an interrupt. Currently only wants for VBlank, so a routine must be put in place when other interrupts are used.

## VBlank

- Push wShadowOAM to OAM
- Collect the input

# Limited Tiles

Scales' main gimmick is the use of 3 main characters with unique sprites and items, and this is a huge demand on the limited number of tiles. While the GBC mode will have the freedom to splurge, the Gameboy's limited graphical capabilities mean that we need to be extremely careful with the character's tiles. The only limitation I gave myself was that I would keep them within the OAM-exclusive tiles.

This is how they are structured:
- Standing/walking frames: 16 tiles each (48 total)
- "Use" frames: 6 tiles each (18 total)
    - This is done by including just a single outstretched arm, which can be flipped to stretch both.
- Item frames: 8 tiles each (24 total)
    - Items, When equipped, load their special effects into these slots. (Arrows, Sword, Spell, etc)

Total: 90 / 128 tiles, leaving 38 open.

# Entities

## The Entity Array

The entity array is an array of active entity information, such as the entity's script and location. The array is iterated once per process loop, which checks for valid data by reading the first byte and confirming it is not 0. This means that all entity data, as well as the entity array code must by on the same bank, but not on bank 0.

When a valid entity is found it's script will be called, and the `bc` register may be used in the script to identify the current entity's data. The `FindEntity` macro uses the `bc` register to locate the entity within the entity array, plus 2, since the script pointer is not needed. The script is then responsible for its entity AI, as well as pushing its metasprite into Shadow OAM.