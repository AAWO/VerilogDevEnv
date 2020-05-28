# Author    : Andrzej Wojciechowski (AAWO)
# Copyright : Andrzej Wojciechowski (AAWO)
# --------------------------------------------
# cocotb makefile
TOPLEVEL_LANG = verilog
PWD=$(shell pwd)
TOPDIR=$(PWD)/..
PYTHONPATH := $(TOPDIR)/tb:$(PYTHONPATH)

BLOCK ?= FIFO

SIM = icarus
SIM_BUILD = $(TOPDIR)/run/$(BLOCK)/sim_build
export USER_DIR:=$(TOPDIR)/run/$(BLOCK)

# TOPLEVEL - last module in file
TOPLEVEL = $(shell tail -n 1 $(BLOCK)_file_list.txt | sed 's/.*\/\(.*\)\..*/\1/' )

# include _libs directory
COMPILE_ARGS += -I$(TOPDIR)/src/libs/

export PAR_TYPE ?= RAND

include makefile.iveriargs
COMPILE_ARGS += $(COMPILE_PARAMS)

# DUT
SRC_LIST = $(shell cat $(BLOCK)_file_list.txt)
VERILOG_SOURCES = $(foreach file,$(SRC_LIST),$(TOPDIR)/$(file))

export TOPLEVEL_LANG

MODULE = $(BLOCK)_tb
export COCOTB_RESULTS_FILE = $(TOPDIR)/run/$(BLOCK)/results.xml

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim

clean::
	-@rm -rf $(TOPDIR)/run/$(BLOCK)
