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

# Entities

## The Entity Array

The entity array is an array of active entity information, such as the entity's script and location. The array is iterated once per process loop, which checks for valid data by reading the first byte and confirming it is not 0. This means that all entity data, as well as the entity array code must by on the same bank, but not on bank 0.

When a valid entity is found it's script will be called, and the `bc` register may be used in the script to identify the current entity's data. The `FindEntity` macro uses the `bc` register to locate the entity within the entity array, plus 2, since the script pointer is not needed. The script is then responsible for its entity AI, as well as pushing its metasprite into Shadow OAM.