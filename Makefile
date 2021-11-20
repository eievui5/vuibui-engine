
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

ROM = bin/vuibui.gb

# 0x1B is MBC5 with RAM + Battery
MBC := 0x1B
# 0x02 is one bank of SRAM
SRAMSIZE := 0x02
VERSION := 0

MAP_OFFSETS := gfx/ui/inventory:128 gfx/ui/gameover:0

INCDIRS  = src/ src/include/ src/vbstd/
WARNINGS = all extra

ASFLAGS  = -p 0xFF -h $(addprefix -i, $(INCDIRS)) $(addprefix -W, $(WARNINGS))
LDFLAGS  = -p 0xFF -w -S romx=64
FIXFLAGS = -p 0xFF -v -i "VUIB" -k "EV" -l 0x33 -m $(MBC) \
           -n $(VERSION) -r $(SRAMSIZE) -t "VuiBui     "

# The list of "root" ASM files that RGBASM will be invoked on
SRCS := $(shell find src -name '*.asm')

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

###############################################
#                                             #
#                 COMPILATION                 #
#                                             #
###############################################

# How to build a ROM
bin/%.gb bin/%.sym bin/%.map: $(patsubst src/%.asm, obj/%.o, $(SRCS))
	@mkdir -p $(@D)
	$(RGBLINK) $(LDFLAGS) -m bin/$*.map -n bin/$*.sym -o bin/$*.gb $^ \
	&& $(RGBFIX) -v $(FIXFLAGS) bin/$*.gb

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
	$(RGBGFX) -u -o $@ $<

# Convert .png files into .1bpp files.
res/%.1bpp: res/%.png
	@mkdir -p $(@D)
	$(RGBGFX) -d 1 -o $@ $<

# Convert .png files into .h.2bpp files (-h flag).
res/%.h.2bpp: res/%.png
	@mkdir -p $(@D)
	$(RGBGFX) -h -o $@ $<

# Convert .png files into .h.1bpp files (-h flag).
res/%.h.1bpp: res/%.png
	@mkdir -p $(@D)
	$(RGBGFX) -d 1 -h -o $@ $<

res/%.pal.json: res/%.png
	@mkdir -p $(@D)
	superfamiconv palette -M gb -j $@ -i $<

# Convert .png files into .pal files.
res/%.pal: res/%.png
	@mkdir -p $(@D)
	$(RGBGFX) -p $@ $<

# Convert .json files into .tilemap files.
res/%.tilemap: res/%.json
	@mkdir -p $(@D)
	python3 tools/tiledbin.py -d $(patsubst src/res/%.json, res/%.roomscript, $<) -o $@ $<

res/%.tilemap: res/%.png res/%.pal.json res/%.2bpp
	@mkdir -p $(@D)
	superfamiconv -R -M gb -T $(lastword $(subst :, ,$(filter $*:%,$(MAP_OFFSETS)))) -t res/$*.2bpp -p res/$*.pal.json -i $< -m $@
#	$(RGBGFX) -u -t $@ $<

# Metatile data conversion.
res/%.mtile res/%.mtiledata: res/%.png bin/metamaker
	@mkdir -p $(@D)
#	Do not optimize these 2bpp files. `metamaker` relies on unoptimized tiles to
#	create the output data. RGBGFX will output the data that metamaker expects,
#	so this is fine.
	$(RGBGFX) -o $(patsubst src/res/%.png, res/%.mtile, $<) $<
	./bin/metamaker -m $@ -w 1 -O 128 -i $(patsubst src/res/%.png, res/%.mtile, $<)

res/%.asm: res/%.world
	@mkdir -p $(@D)
	python3 tools/tiledworld.py -o $@ -i res/$*.inc $<

################################################
#                                              #
#                    TOOLS                     #
#                                              #
################################################

bin/metamaker: tools/metamaker.cpp
	@mkdir -p $(@D)
	g++ -std=c++17 -O3 -march=native -o $@ $<

# Catch non-existent files
# KEEP THIS LAST!!
%:
	@false
