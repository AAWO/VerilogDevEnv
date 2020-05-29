#!/bin/bash
# File Name : checkDepend.sh
# Author    : Andrzej Wojciechowski (AAWO)
# Copyright : Andrzej Wojciechowski (AAWO)
# --------------------------------------------

cmd_dict=( "make" "Python 3" "Icarus Verilog (iverilog)" "GTKwave" "Verilator" "cocotb" "Yosys" "Modelsim" )
cmd_array=( "make" "python3" "iverilog" "gtkwave" "verilator" "cocotb-config" "yosys" "vsim" )

for i in "${!cmd_array[@]}"
do
   if [ -x "$(command -v ${cmd_array[$i]})" ]
   then
      echo "OK - ${cmd_dict[$i]} is installed"
   else
      echo "WARNING - ${cmd_dict[$i]} is not installed"
   fi
done
