
## Downloading

You can simply clone the repository using Git, or if you just want to download this, click the `Clone or download` button up and to the right of this. This repo is also usable as a GitHub template for creating new repositories.

## Setting up

Make sure you have [RGBDS](https://github.com/rednex/rgbds), at least version 0.4.0, and GNU Make installed. Python 3 is required for the PB16 compressor bundled as a usage example, but that script is optional.

## Compiling

Simply open you favorite command prompt / terminal, place yourself in this directory (the one the Makefile is located in), and run the command `make`. This should create a bunch of things, including the output in the `bin` folder.

If you get errors that you don't understand, try running `make clean`. If that gives the same error, try deleting the `deps` folder. If that still doesn't work, try deleting the `bin` and `obj` folders as well. If that still doesn't work, you probably did something wrong yourself.

### Libraries

- [structs in RGBDS](https://github.com/ISSOtm/rgbds-structs)
- Also hUGE Driver and Pinobatch's input routine. If you're reading this, yell at me for not linking them yet.
