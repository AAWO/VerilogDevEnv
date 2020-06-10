# File Name : Vivado_compile.tcl
# Author    : Andrzej Wojciechowski (AAWO)
# Copyright : Andrzej Wojciechowski (AAWO)
# --------------------------------------------
set BLOCK [lindex $argv 0]
set TASK  [lindex $argv 1]
set TGT_I [lindex $argv 2]
# Create work directory
set workDir $BLOCK
file mkdir "./Vivado/$workDir"
# Clean-up work directory
set workDir_files [glob -nocomplain "./Vivado/$workDir/*"]
if {[llength $workDir_files] != 0} {
   puts "Removing contents of directory ./Vivado/$workDir"
   eval file delete -force [glob -nocomplain ./Vivado/$workDir/*]
} else {
   puts "Created directory ./Vivado/$workDir"
}

# Set target index to 0 if not defined
if {$TGT_I eq ""} {
   set TGT_I 0
}

# Read target FPGA
set target_filepath "./Vivado/target.txt"
if {![file exists $target_filepath]} {
   error "ERROR! No target specified. File $target_filepath not found"
} else {
   set file_target [open $target_filepath]
   # Read targets file as list and remove empty elements
   set targets [lsearch -all -inline -not -exact [split [read $file_target] "\n"] {}]
   close $file_target
   puts "Found targets: $targets"
   puts "Target index: $TGT_I"
   if {![expr $TGT_I < [llength $targets]]} {
      error "ERROR! Target index is greater than number of defined targets"
   }
   set target [lindex $targets $TGT_I]
   puts "Target device: $target"
}

create_project -force -part $target top "./Vivado/$workDir"

# Add XDC files
set xdc_files [glob -nocomplain "./Vivado/*.xdc"]
if {$xdc_files ne ""} {
   add_files -fileset constrs_1 $xdc_files
   puts "Added XDC files: $xdc_files"
} else {
   puts "No XDC files found in directory ./Vivado"
}

# Add directories with included files
set_property include_dirs {src/libs tb/common} [current_fileset]

# Add design files
set top_level ""
set file_list [open "./run/${BLOCK}_file_list.txt"]
set fl_lines [split [read $file_list] "\n"]
close $file_list
foreach line $fl_lines {
   if {$line ne ""} {
      puts $line
      if {[string range $line 0 2] eq "tb/"} {
         # TB files
         add_files -fileset sim_1 $line
         set_property file_type SystemVerilog [get_files $line]
         set top_level_sim [string range $line [string last "/" $line]+1 [string last "." $line]-1]
      } else {
         # design files
         add_files $line
         set top_level [string range $line [string last "/" $line]+1 [string last "." $line]-1]
      }
   }
}
puts "Top level entity: $top_level"

set_property top $top_level [current_fileset]

switch $TASK {
   sim {
      set_property top $top_level_sim [get_filesets sim_1]
      launch_simulation
      restart
      run all
   }
   synth {
      # Launch synthesis
      launch_runs synth_1
      wait_on_run synth_1
   }
   impl {
      # Launch synthesis
      launch_runs synth_1
      wait_on_run synth_1
      # Physical optimization
      set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
      # Launch implementation and generate bitstream
      launch_runs impl_1 -to_step write_bitstream
      wait_on_run impl_1
      puts "Implementation finished"
   }
   default {

   }
}
