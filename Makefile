
.SUFFIXES:

################################################
#                                              #
#             CONSTANT DEFINITIONS             #
#                                              #
################################################

# Program constants
RGBDS   :=

RGBASM  := $(RGBDS)rgbasm
RGBLINK := $(RGBDS)rgblink
RGBFIX  := $(RGBDS)rgbfix
RGBGFX  := $(RGBDS)rgbgfx

ROM = bin/$(ROMNAME).$(ROMEXT)

# Argument constants
INCDIRS  = src/ src/include/ src/vbstd/
WARNINGS = all extra
ASFLAGS  = -p $(PADVALUE) $(addprefix -i, $(INCDIRS)) $(addprefix -W, $(WARNINGS))
LDFLAGS  = -p $(PADVALUE) -S romx=64
FIXFLAGS = -p $(PADVALUE) -v -i "$(GAMEID)" -k "$(LICENSEE)" -l $(OLDLIC) -m $(MBC) -n $(VERSION) -r $(SRAMSIZE) -t $(TITLE)

# The list of "root" ASM files that RGBASM will be invoked on
SRCS := $(shell find src -name '*.asm')

## Project-specific configuration
# Use this to override the above
include project.mk

################################################
#                                              #
#                    TARGETS                   #
#                                              #
################################################

# `all` (Default target): build the ROM
all: $(ROM)
.PHONY: all

# `clean`: Clean temp and bin files
clean:
	rm -rf bin
	rm -rf obj
	rm -rf dep
	rm -rf res
.PHONY: clean

# `rebuild`: Build everything from scratch
# It's important to do these two in order if we're using more than one job
rebuild:
	$(MAKE) clean
	$(MAKE) all
.PHONY: rebuild

usage: all
	./tools/romusage bin/$(ROMNAME).map -g
.PHONY: usage

###############################################
#                                             #
#                 COMPILATION                 #
#                                             #
###############################################

# How to build a ROM
bin/%.$(ROMEXT) bin/%.sym bin/%.map: $(patsubst src/%.asm, obj/%.o, $(SRCS))
	@mkdir -p $(@D)
	$(RGBLINK) $(LDFLAGS) -m bin/$*.map -n bin/$*.sym -o bin/$*.$(ROMEXT) $^ \
	&& $(RGBFIX) -v $(FIXFLAGS) bin/$*.$(ROMEXT)

# `.mk` files are auto-generated dependency lists of the "root" ASM files, to save a lot of hassle.
# Also add all obj dependencies to the dep file too, so Make knows to remake it
# Caution: some of these flags were added in RGBDS 0.4.0, using an earlier version WILL NOT WORK
# (and produce weird errors)
obj/%.o dep/%.mk: src/%.asm
	@mkdir -p $(patsubst %/, %, $(dir obj/$* dep/$*))
	$(RGBASM) $(ASFLAGS) -M dep/$*.mk -MG -MP -MQ obj/$*.o -MQ dep/$*.mk -o obj/$*.o $<

ifneq ($(MAKECMDGOALS),clean)
-include $(patsubst src/%.asm, dep/%.mk, $(SRCS))
endif

################################################
#                                              #
#                RESOURCE FILES                #
#                                              #
################################################


# By default, asset recipes convert files in `res/` into other files in `res/`
# This line causes assets not found in `res/` to be also looked for in `src/res/`
# "Source" assets can thus be safely stored there without `make clean` removing them
VPATH := src

# Convert .png files into .2bpp files.
res/%.2bpp: res/%.png
	@mkdir -p $(@D)
	$(RGBGFX) -u -o $@ $^

# Convert .png files into .1bpp files.
res/%.1bpp: res/%.png
	@mkdir -p $(@D)
	$(RGBGFX) -d 1 -o $@ $^

# Convert .png files into .h.2bpp files (-h flag).
res/%.h.2bpp: res/%.png
	@mkdir -p $(@D)
	$(RGBGFX) -h -o $@ $^

# Convert .png files into .h.1bpp files (-h flag).
res/%.h.1bpp: res/%.png
	@mkdir -p $(@D)
	$(RGBGFX) -d 1 -h -o $@ $^

# Convert .png files into .pal files.
res/%.pal: res/%.png
	@mkdir -p $(@D)
	$(RGBGFX) -p $@ $^

# Convert .json files into .tilemap files.
res/%.tilemap: res/%.json
	@mkdir -p $(@D)
	python3 ./tools/tiledbin.py $^ $@

res/%.tilemap: res/%.png
	@mkdir -p $(@D)
	$(RGBGFX) -u -t $@ $^

# Metatile data conversion.
res/%.mtile res/%.mtiledata: res/%.png
	@mkdir -p $(@D)
#	Do not optimize these 2bpp files. `metamaker` relies on unoptimized tiles to
#	create the output data. RGBGFX will output the data that metamaker expects,
#	so this is fine.
	$(RGBGFX) -o $(patsubst src/res/%.png, res/%.mtile, $^) $^
#	The width flag should be changed to 1 in the future. For now, it is 3.
	./tools/metamaker -m $@ -w 3 -O 128 -i $(patsubst src/res/%.png, res/%.mtile, $^)


# Catch non-existent files
# KEEP THIS LAST!!
%:
	@false
