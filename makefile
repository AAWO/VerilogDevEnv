# Author    : Andrzej Wojciechowski (AAWO)
# Copyright : Andrzej Wojciechowski (AAWO)
# --------------------------------------------
BLOCK    ?= FIFO
SIM      ?= iverilog
LINT     ?= verilator
IDE      ?= ""
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
	@echo "   sim:           - build design"
	@echo "   sim_gui:       - build design and run simulation with GUI"
	@echo "   lint:          - lint design with verilator"
	@echo "   synth:         - synthesize design with yosys or selected IDE"
	@echo "   impl:          - implement design with selected IDE"
	@echo ""

help-vars:
	@echo "Supported variables:"
	@echo "   BLOCK:         - design to anlyze"
	@echo "   SIM:           - simulation-tool: iverilog"
	@echo "   LINT:          - lint-tool: verilator"
	@echo "   IDE:           - FPGA IDE: Vivado"
	@echo "   PAR_TYPE:      - parameters type: rand (default), min, max, def"
	@echo ""

checktools:
	run/checkDepend.sh

TB_PY=$(shell find tb/ -maxdepth 1 -name '*.py' -print)
TB_V =$(shell find tb/ -maxdepth 1 -name '*.v' -print)
TOPLEVEL=$(shell tail -n 1 run/$(BLOCK)_file_list.txt | sed 's/.*\/\(.*\)\..*/\1/' )

include run/makefile.iveriargs

sim: | $(BLOCK)
ifeq ($(SIM), MOD)
# Run ModelSim
	vlib work
	vlog -sv -work work +incdir+src/libs/ +incdir+tb/common/ -f run/$(BLOCK)_file_list.txt
	vsim -c $(TOPLEVEL) -do 'run -all'
else ifeq ($(IDE), Vivado)
sim:
# Vivado
	rm ./Vivado/*.backup.log ./Vivado/*.backup.jou
	vivado -mode batch -log Vivado/setup.log -jou Vivado/setup.jou -source run/Vivado_compile.tcl -notrace -tclargs $(BLOCK) sim
else ifneq (,$(findstring $(BLOCK)_tb,$(TB_PY)))
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

ifeq ($(SIM), MOD)
# ModelSim
sim_gui:
	vlib work
	vlog -sv -work work +incdir+src/libs/ +incdir+tb/common/ -f run/$(BLOCK)_file_list.txt
	vsim $(TOPLEVEL) -do run/$(BLOCK)_wave.do -do run/comp_mod.tcl -do 'run -all'
else ifeq ($(IDE), Vivado)
sim_gui:
# Vivado
	rm ./Vivado/*.backup.log ./Vivado/*.backup.jou
	vivado -mode gui -log Vivado/setup.log -jou Vivado/setup.jou -source run/Vivado_compile.tcl -notrace -tclargs $(BLOCK) sim
else
sim_gui: | sim
	gtkwave run/$(BLOCK)/$(BLOCK).vcd run/$(BLOCK)_wave.gtkw
endif

lint:
	verilator --lint-only -Wall -Isrc/libs/ run/verilator_config.vlt `sed '/^tb/ d' run/$(BLOCK)_file_list.txt`

synth:
ifeq ($(IDE), Vivado)
	rm ./Vivado/*.backup.log ./Vivado/*.backup.jou
	vivado -mode batch -log Vivado/setup.log -jou Vivado/setup.jou -source run/Vivado_compile.tcl -notrace -tclargs $(BLOCK) synth
else
	yosys -o $(BLOCK)_synth.v -p "read_verilog -Isrc/libs/ `sed '/^tb/d' run/$(BLOCK)_file_list.txt | tr '\n' ' '`; synth -auto-top -flatten"
endif

impl:
ifeq ($(IDE), Vivado)
	rm ./Vivado/*.backup.log ./Vivado/*.backup.jou
	vivado -mode batch -log Vivado/setup.log -jou Vivado/setup.jou -source run/Vivado_compile.tcl -notrace -tclargs $(BLOCK) impl
endif

$(BLOCK):
	mkdir -p run/$@

