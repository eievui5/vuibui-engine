
.SUFFIXES:

################################################
#                                              #
#             CONSTANT DEFINITIONS             #
#                                              #
################################################

# Directory constants
SRCDIR := src
BINDIR := bin
OBJDIR := obj
DEPDIR := dep
RESDIR := res

# Program constants
ifneq ($(OS),Windows_NT)
    # POSIX OSes
    RM_RF := rm -rf
    MKDIR_P := mkdir -p
	RGBDS   := 
else
    # Windows
    RM_RF := -rm -rf
    MKDIR_P := -mkdir -p
	RGBDS   := rgbds/windows/
endif

RGBASM  := $(RGBDS)rgbasm
RGBLINK := $(RGBDS)rgblink
RGBFIX  := $(RGBDS)rgbfix
RGBGFX  := $(RGBDS)rgbgfx

ROM = $(BINDIR)/$(ROMNAME).$(ROMEXT)

# Argument constants
INCDIRS  = $(SRCDIR)/ $(SRCDIR)/include/
WARNINGS = all extra
ASFLAGS  = -p $(PADVALUE) $(addprefix -i,$(INCDIRS)) $(addprefix -W,$(WARNINGS))
LDFLAGS  = -p $(PADVALUE)
FIXFLAGS = -p $(PADVALUE) -v -i "$(GAMEID)" -k "$(LICENSEE)" -l $(OLDLIC) -m $(MBC) -n $(VERSION) -r $(SRAMSIZE) -t $(TITLE)

# The list of "root" ASM files that RGBASM will be invoked on
SRCS = $(wildcard $(SRCDIR)/*.asm) \
	$(wildcard $(SRCDIR)/entities/*.asm) \
	$(wildcard $(SRCDIR)/res/metasprites/*.asm) \
	$(wildcard $(SRCDIR)/libs/*.asm) \
	$(wildcard $(SRCDIR)/scripts/*.asm) \
	$(wildcard $(SRCDIR)/res/gfx/*.asm) \
	$(wildcard $(SRCDIR)/res/tilesets/*.asm) \
	$(wildcard $(SRCDIR)/res/maps/*.asm)

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
	$(RM_RF) $(BINDIR)
	$(RM_RF) $(OBJDIR)
	$(RM_RF) $(DEPDIR)
	$(RM_RF) $(RESDIR)
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
$(BINDIR)/%.$(ROMEXT) $(BINDIR)/%.sym $(BINDIR)/%.map: $(patsubst $(SRCDIR)/%.asm,$(OBJDIR)/%.o,$(SRCS))
	@$(MKDIR_P) $(@D)
	$(RGBASM) $(ASFLAGS) -o $(OBJDIR)/build_date.o $(SRCDIR)/res/build_date.asm
	$(RGBLINK) $(LDFLAGS) -m $(BINDIR)/$*.map -n $(BINDIR)/$*.sym -o $(BINDIR)/$*.$(ROMEXT) $^ $(OBJDIR)/build_date.o \
	&& $(RGBFIX) -v $(FIXFLAGS) $(BINDIR)/$*.$(ROMEXT)
ifneq ($(OS),Windows_NT)
	./tools/romusage $(BINDIR)/$(ROMNAME).map -g
else
	./tools/romusage.exe $(BINDIR)/$(ROMNAME).map -g
endif

# `.mk` files are auto-generated dependency lists of the "root" ASM files, to save a lot of hassle.
# Also add all obj dependencies to the dep file too, so Make knows to remake it
# Caution: some of these flags were added in RGBDS 0.4.0, using an earlier version WILL NOT WORK
# (and produce weird errors)
$(OBJDIR)/%.o $(DEPDIR)/%.mk: $(SRCDIR)/%.asm
	@$(MKDIR_P) $(patsubst %/,%,$(dir $(OBJDIR)/$* $(DEPDIR)/$*))
	$(RGBASM) $(ASFLAGS) -M $(DEPDIR)/$*.mk -MG -MP -MQ $(OBJDIR)/$*.o -MQ $(DEPDIR)/$*.mk -o $(OBJDIR)/$*.o $<

ifneq ($(MAKECMDGOALS),clean)
-include $(patsubst $(SRCDIR)/%.asm,$(DEPDIR)/%.mk,$(SRCS))
endif

################################################
#                                              #
#                RESOURCE FILES                #
#                                              #
################################################


# By default, asset recipes convert files in `res/` into other files in `res/`
# This line causes assets not found in `res/` to be also looked for in `src/res/`
# "Source" assets can thus be safely stored there without `make clean` removing them
VPATH := $(SRCDIR)

# Define how to compress files using the PackBits16 codec
# Compressor script requires Python 3
$(RESDIR)/%.pb16: ./tools/pb16.py $(RESDIR)/%.2bpp
	@$(MKDIR_P) $(@D)
	$^ $@

# Convert .png files into .2bpp files.
$(RESDIR)/%.2bpp: $(RESDIR)/%.png
	@$(MKDIR_P) $(@D)
	$(RGBGFX) -o $@ $^

# Convert .png files into .1bpp files.
$(RESDIR)/%.1bpp: $(RESDIR)/%.png
	@$(MKDIR_P) $(@D)
	$(RGBGFX) -d 1 -o $@ $^

# Convert .png files into .h.2bpp files (-h flag)
$(RESDIR)/%.h.2bpp: $(RESDIR)/%.png
	@$(MKDIR_P) $(@D)
	$(RGBGFX) -h -o $@ $^

# Convert .png files into .pal files
$(RESDIR)/%.pal: $(RESDIR)/%.png
	@$(MKDIR_P) $(@D)
	$(RGBGFX) -p $@ $^

# Catch non-existent files
# KEEP THIS LAST!!
%:
	@false