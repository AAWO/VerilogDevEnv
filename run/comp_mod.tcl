# File Name : comp_mod.tcl
# Author    : Andrzej Wojciechowski (AAWO)
# Copyright : Andrzej Wojciechowski (AAWO)
# --------------------------------------------
# Compile out of date files
proc r {} {
   global last_compile_time file_list

   if [catch {set last_compile_time}] {
      set last_compile_time 0
   }

   foreach file $file_list {
      puts "$file"
      if { $last_compile_time < [file mtime $file] } {
         vlog -sv -work work +incdir+src/_libs/ +incdir+tb/_common/ $file
         set last_compile_time 0
      }
   }
}

proc rr {} {
   global last_compile_time
   set last_compile_time 0
   r
}

proc re {} {
   restart
   run -all
}

# get wave_filename and substract "run/" and "_wave.do"
# "; list" suffix prevents return value printout by shell
set BLOCK [string range [lindex $argv 2] 4 end-8]; list
set file_list [read [open run/${BLOCK}_file_list.txt r]]
set last_compile_time [clock seconds]; list
