#!/bin/bash

declare -A cmd_dict=( ["make"]="make" ["python3"]="Python 3" ["iverilog"]="Icarus Verilog (iverilog)" ["gtkwave"]="GTKwave" ["verilator"]="Verilator" ["cocotb-config"]="cocotb" ["yosys"]="Yosys" )
cmd_array=( "make" "python3" "iverilog" "gtkwave" "verilator" "cocotb-config" "yosys" )

for i in "${!cmd_array[@]}"
do
   #echo "$cmd - ${cmd_array[$i]}"
   
   if [ -x "$(command -v ${cmd_array[$i]})" ]
   then
      echo "OK - ${cmd_dict[${cmd_array[$i]}]} is installed"
   else
      echo "WARNING - ${cmd_dict[${cmd_array[$i]}]} is not installed"
   fi
done
