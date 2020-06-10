## VerilogDevEnv - Verilog Development Environment

VerilogDevEnv is an environment consisting of directory structure and open-source as well as commercial tools scripts designed for digital design development using Verilog HDL.

Current tools used by VerilogDevEnv:
- make
- Icarus Verilog (iverilog)
- Verilator
- cocotb 
- Yosys
- ModelSim

The example FIFO module with testbench is provided

### Directory structure
```
- run/                     - work directory for configurations and outputs
  - params/                - directory for parameters definitions
  - makefile               - makefile for running tests using cocotb
  - randInt.py             - pseudo-random values generator
  - makefile.iveriargs     - makefile sippet generating iverilog flags with module's parameters
  - verilator_config.vlt   - Verilator configuration file
  - checkDepend.sh         - script for verification if required tools are installed and can be run
  - comp_mod.tcl           - supporting functions for ModelSim simulation
  - Vivado_compile.tcl     - Vivado compilation script
- src/                     - directory for source design files
  - libs/                  - directory with libraries included in other modules
- tb/                      - directory for testbenches
  - common/                - directory for common test files included in other testbenches
- Vivado/                  - directory with files required for compilation in Vivado, like .xdc files, and project files
  - target.txt             - file containing name of target FPGA device
```

### Test configuration

In order to run a test, a configuration file must be provided containing all design files (including testbench) required. The name of the file must consists of *name* followed by *_file_list.txt*.

For example - to define a test for provided FIFO module:
- testbench file is called 'FIFO_tb.v', so let's make the name *FIFO*,
- a file 'run/FIFO_file_list.txt' should be created containing patch to required source files (DualPortRAM and FIFO). The last line in the file should be path to testbench file (FIFO_tb),

To run a test, *make* command should be invoked from top directory with argument *BLOCK=* followed by test name.

### Supported targets

- help       - prints help
- checktools - verify if required tools are installed and can be run
- sim        - runs simulation with iverilog (and optionally cocotb)
- lint       - runs code linting with Verilator
- synth      - runs synthesis with Yosys or Vivado
- impl       - implement design with Vivado

### Defining parameters

In order to define testbench's parameters values a file "run/params/*name*_params.txt" should be created. The file should contain in each line the name of the parameter, minimum value, maximum value and optional step.

When running simulation the parameters values can be set as: 
- RAND - random,
- MIN  - minimum,
- MAX  - maximum,
- DEF  - default (defined in testbench parameter's definition).
