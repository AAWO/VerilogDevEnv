# Author    : Andrzej Wojciechowski (AAWO)
# Copyright : Andrzej Wojciechowski (AAWO)
# --------------------------------------------
BLOCK    ?= FIFO
SIM      ?= iverilog
LINT     ?= verilator
PAR_TYPE ?= rand

TOPDIR=$(PWD)

.PHONY: help help-targets help-vars sim lint unit-tests clean

help: | help-targets help-vars

help-targets:
	@echo "Supported targets:"
	@echo "   help:          - main help page"
	@echo "   help-targets:  - list of supported targets"
	@echo "   help-vars:     - list of supported variables"
	@echo "   checktools:    - verify if required tools are installed"
	@echo "   sim:           - build design with iverilog"
	@echo "   lint:          - lint design with verilator"
	@echo "   synth:         - synthesize design with yosys"
	@echo ""

help-vars:
	@echo "Supported variables:"
	@echo "   BLOCK:         - design to anlyze"
	@echo "   SIM:           - simulation-tool: iverilog"
	@echo "   LINT:          - lint-tool: verilator"
	@echo "   PAR_TYPE:      - parameters type: rand (default), min, max, def"
	@echo ""

checktools:
	run/checkDepend.sh

TB_PY=$(shell find tb/ -maxdepth 1 -name '*.py' -print)
TB_V =$(shell find tb/ -maxdepth 1 -name '*.v' -print)
TOPLEVEL=$(shell tail -n 1 run/$(BLOCK)_file_list.txt | sed 's/.*\/\(.*\)\..*/\1/' )

include run/makefile.iveriargs

sim: | $(BLOCK)
ifneq (,$(findstring $(BLOCK)_tb,$(TB_PY)))
# TB file in python - use cocotb
	@echo "Found TB Python file - using cocotb with $(SIM) sim-tool"
	$(MAKE) -C run TEST_NAME=$(BLOCK) PAR_TYPE=$(PAR_TYPE)
else ifneq (,$(findstring $(BLOCK)_tb,$(TB_V)))
# TB file in verilog - use sim-tool
	@echo "Found TB Verilog file - using $(SIM)"
	iverilog -Isrc/libs/ -Itb/common -g2012 -tvvp -Wall -DIVERILOG $(COMPILE_PARAMS) \
	-c run/$(BLOCK)_file_list.txt -s $(TOPLEVEL) -o run/$(BLOCK)/$(BLOCK).vvp
	vvp run/$(BLOCK)/$(BLOCK).vvp
else
# TB file extension not matched - error
	$(error TB file $(BLOCK)_tb not found. Supported file extension: [.v, .py])
endif

lint:
	verilator --lint-only -Wall -Isrc/libs/ run/verilator_config.vlt `sed '/^tb/ d' run/$(BLOCK)_file_list.txt`

synth:
	yosys -o $(BLOCK)_synth.v -p "read_verilog -Isrc/libs/ `sed '/^tb/d' run/$(BLOCK)_file_list.txt | tr '\n' ' '`; synth -auto-top -flatten"

$(BLOCK):
	mkdir -p run/$@

