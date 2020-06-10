#!/bin/bash
# File Name : checkDepend.sh
# Author    : Andrzej Wojciechowski (AAWO)
# Copyright : Andrzej Wojciechowski (AAWO)
# --------------------------------------------

cmd_dict=( "make" "Python 3" "Icarus Verilog (iverilog)" "GTKwave" "Verilator" "cocotb" "Yosys" "ModelSim" "Vivado" )
cmd_array=( "make" "python3" "iverilog" "gtkwave" "verilator" "cocotb-config" "yosys" "vsim" "vivado" )

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

for i in "${!cmd_array[@]}"
do
   if [ -x "$(command -v ${cmd_array[$i]})" ]
   then
      echo -e "${GREEN}OK${NC} - ${cmd_dict[$i]} found"
   else
      echo -e "${YELLOW}WARNING${NC} - ${cmd_dict[$i]} not found"
   fi
done
