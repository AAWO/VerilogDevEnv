// File Name : Defines.vh
// Author    : Andrzej Wojciechowski (AAWO)
// Copyright : Andrzej Wojciechowski (AAWO)
// --------------------------------------------
`timescale 1ns / 1ps
`include "Defines.vh"
`include "AssertLib.v"

`define CLK_PERIOD   10

module FIFO_tb;
parameter DATA_W     =  64;
parameter FIFO_DEPTH =  256;

reg clk;
reg rst;
reg i_wr_en;
reg i_rd_en;
wire o_empty;
wire o_full;
reg[DATA_W-1:0] i_data;
wire[DATA_W-1:0] o_data;

wire[DATA_W-1:0] FIFO_data [0:FIFO_DEPTH-1];
reg o_empty_reg;
reg o_full_reg;
reg[DATA_W-1:0] o_data_reg;

reg data_test_en;
reg [DATA_W-1:0] data [0:FIFO_DEPTH-1];
integer ii;


FIFO_DPRAM #(
   .DATA_W(DATA_W),
   .FIFO_DEPTH(FIFO_DEPTH))
FIFO_DPRAM (
   .clk(clk),
   .rst(rst),
   .i_wr_en(i_wr_en),
   .i_rd_en(i_rd_en),
   .o_empty(o_empty),
   .o_full(o_full),
   .i_data(i_data),
   .o_data(o_data)
);


always #(`CLK_PERIOD / 2) clk = !clk;

always @(posedge clk) begin
   o_full_reg  <= o_full;
   o_empty_reg <= o_empty;
   o_data_reg  <= o_data;
end

assign FIFO_data = FIFO_DPRAM.DualPortRAM.memory;


initial begin
   `ifdef IVERILOG
      $dumpfile("run/FIFO/FIFO.vcd");
      $dumpvars;
   `endif
   clk      = 1'b1;
   rst      = 1'b0;
   i_wr_en  = 1'b0;
   i_rd_en  = 1'b0;
   i_data   = 0;

   #(3.5*`CLK_PERIOD) rst = 1'b1;

   check_rstStates;
   check_FIFO_dataHold(100);
   check_FIFO_dataRead(100);
   check_FIFO_fullFlag(3);
   check_FIFO_emptyFlag(3);
   check_FIFO_simultaneous_RW;

   $finish;
end


task zero_input;
begin
   i_wr_en  = 1'b0;
   i_rd_en  = 1'b0;
   i_data   = 0;
end
endtask


task check_rstStates;
   integer i;
begin
   $display("check_rstStates - time: %d", $time);
   rst   = 1'b0;
   @(negedge clk);
   assertEzero(FIFO_DPRAM.wr_ptr,    "FIFO wr_ptr is not 0 during rst!");
   assertEzero(FIFO_DPRAM.rd_ptr,    "FIFO rd_ptr is not 0 during rst!");
   assertEzero(FIFO_DPRAM.looped,    "FIFO looped is not 0 during rst!");
   assertEzero(FIFO_DPRAM.full,      "FIFO full is not 0 during rst!");
   assertEeq(FIFO_DPRAM.empty, 1, "FIFO empty is not 1 during rst!");
   for (i=0; i<FIFO_DEPTH; i=i+1) begin
      assertEzero(FIFO_DPRAM.DualPortRAM.memory[i],    "FIFO memory not all 0 during rst!");
   end
   
   #(3*`CLK_PERIOD) rst = 1'b1;
   @(negedge clk);
   assertEzero(FIFO_DPRAM.wr_ptr,    "FIFO wr_ptr is not 0 after rst!");
   assertEzero(FIFO_DPRAM.rd_ptr,    "FIFO rd_ptr is not 0 after rst!");
   assertEzero(FIFO_DPRAM.looped,    "FIFO looped is not 0 after rst!");
   assertEzero(FIFO_DPRAM.full,      "FIFO full is not 0 after rst!");
   assertEeq(FIFO_DPRAM.empty, 1, "FIFO empty is not 1 after rst!");
   for (i=0; i<FIFO_DEPTH; i=i+1) begin
      assertEzero(FIFO_DPRAM.DualPortRAM.memory[i],    "FIFO memory not all 0 after rst!");
   end
   assertI("INFO! Task check_rstStates - OK");
end
endtask


task check_FIFO_dataHold;
   input [DATA_W-1:0] data_start_offset;
   reg[DATA_W-1:0] temp_data;
   integer i;
begin
   $display("check_FIFO_dataHold - time: %d", $time);
   temp_data   = data_start_offset;
   i_rd_en     = 1'b0;

   // write FIFO over FULL
   for (i=0; i<FIFO_DEPTH+10; i=i+1) begin
      @(negedge clk);
      temp_data   = temp_data +1;
      i_data      = temp_data;
      i_wr_en     = 1'b1;
   end

   // check data stored in FIFO
   temp_data      = data_start_offset;
   for (i=0; i<FIFO_DEPTH; i=i+1) begin
      temp_data   = temp_data +1;
      assertEeq(FIFO_data[i], temp_data, "FIFO lost data!");
   end

   zero_input;
   assertI("INFO! Task check_FIFO_dataHold - OK");
end
endtask


task check_FIFO_dataRead;
   input [DATA_W-1:0] data_start_offset;
   reg[DATA_W-1:0] temp_data;
   integer i;
begin
   $display("check_FIFO_dataRead - time: %d", $time);
   temp_data   = data_start_offset;
   zero_input;

   // rst FIFO
   rst   = 1'b0;
   #(3*`CLK_PERIOD) rst = 1'b1; 
   // write FIFO full
   for (i=0; i<FIFO_DEPTH; i=i+1) begin
      @(negedge clk);
      temp_data   = temp_data +1;
      i_data      = temp_data;
      i_wr_en     = 1'b1;
   end

   @(negedge clk);
   zero_input;
   @(negedge clk);
   @(negedge clk);
   @(negedge clk);
   temp_data      = data_start_offset+1;
   // check first read value 
   i_rd_en        = 1'b1;
   @(negedge clk);
   assertEeq(o_data, temp_data, "FIFO unexpected o_data value!");
   // check data read from FIFO
   for (i=0; i<FIFO_DEPTH-1; i=i+1) begin
      while (o_data == o_data_reg) begin
         @(negedge clk);
      end
      i_rd_en     = 1'b1;
      temp_data   = temp_data +1;
      assertEeq(o_data, temp_data, "FIFO unexpected o_data value!");
      @(negedge clk);
   end

   zero_input;
   assertI("INFO! Task check_FIFO_dataRead - OK");
end
endtask


task check_FIFO_fullFlag;
   input integer maxWaitTicks;
   integer delta;
   integer i, j, k;
begin
   $display("check_FIFO_fullFlag - time: %d", $time);
   zero_input;

   // set default state - FIFO empty
   while (!o_empty) begin
      @(negedge clk);
      i_rd_en  = 1'b1;
   end

   zero_input;

   // write FIFO empty -> full
   @(negedge clk);
   for (i=0; i<FIFO_DEPTH; i=i+1) begin
      i_data   = $urandom;
      i_wr_en  = 1'b1;
      @(negedge clk);
   end
   zero_input;
   // check after how many ticks full flag is set
   for (i=1; i<maxWaitTicks; i=i+1) begin
      if (o_full && (i <= 1)) begin
         assertIeq_int(o_full, o_full_reg, "FIFO full flag set on empty -> full write after ticks: ", i);
      end
      else begin
         assertWeq_int(o_full, o_full_reg, "FIFO full flag set on empty -> full write after ticks: ", i);
      end
      @(negedge clk);
   end
   assertEeq(o_full, 1, "FIFO full flag set not working on empty -> full write!");

   @(negedge clk);
   i_rd_en  = 1'b1;
   @(negedge clk);
   i_rd_en  = 1'b0;
   // check after how many ticks full flag is unset
   for (i=1; i<10; i=i+1) begin
      if (!o_full) begin
         if ((i <= 1)) begin
            assertIeq_int(o_full, o_full_reg, "FIFO full flag unset after ticks: ", i);
         end
         else begin
            assertWeq_int(o_full, o_full_reg, "FIFO full flag unset after ticks: ", i);
         end
      end
      @(negedge clk);
   end
   assertEeq(o_full, 0, "FIFO full flag unset not working!");

   while (!o_full) begin
      @(negedge clk);
      i_data   = $urandom;
      i_wr_en  = 1'b1;
   end
   zero_input;
   #(3*`CLK_PERIOD) delta = 1;
   // Read N words and write back N words. Increment N
   for (k=0; k<FIFO_DEPTH; k=k+1) begin
      for (i=0; i<delta; i=i+1) begin
         @(negedge clk);
         i_rd_en  = 1'b1;
      end
      i_rd_en  = 1'b0;
      for (i=0; i<delta; i=i+1) begin
         @(negedge clk);
         i_data   = $urandom;
         i_wr_en  = 1'b1;
      end
      i_wr_en  = 1'b0;
      for (j=0; j<maxWaitTicks; j=j+1) begin
         if (!o_full) @(negedge clk);
      end
      assertEeq(o_full, 1, "FIFO full flag malfunction!");
      delta = delta +1;
   end

   zero_input;
   assertI("INFO! Task check_FIFO_fullFlag - OK");
end
endtask


task check_FIFO_emptyFlag;
   input integer maxWaitTicks;
   integer delta;
   integer i, j, k;
begin
   $display("check_FIFO_emptyFlag - time: %d", $time);
   zero_input;

   // set default state - FIFO full
   while (!o_full) begin
      @(negedge clk);
      i_data   = $urandom;
      i_wr_en  = 1'b1;
   end

   zero_input;

   // read FIFO full -> empty
   @(negedge clk);
   for (i=0; i<FIFO_DEPTH; i=i+1) begin
      i_rd_en  = 1'b1;
      @(negedge clk);
   end
   zero_input;
   // check after how many ticks empty flag is set
   for (i=1; i<maxWaitTicks; i=i+1) begin
      if (o_empty && (i <= 1)) begin
         assertIeq_int(o_empty, o_empty_reg, "FIFO empty flag set on full -> empty read after ticks: ", i);
      end
      else begin
         assertWeq_int(o_empty, o_empty_reg, "FIFO empty flag set on full -> empty read after ticks: ", i);
      end
      @(negedge clk);
   end
   assertEeq(o_empty, 1, "FIFO empty flag set not working on full -> empty read!");

   @(negedge clk);
   i_data   = $urandom;
   i_wr_en  = 1'b1;
   @(negedge clk);
   i_wr_en  = 1'b0;
   // check after how many ticks empty flag is unset
   for (i=1; i<10; i=i+1) begin
      if (!o_empty) begin
         if ((i <= 1)) begin
            assertIeq_int(o_empty, o_empty_reg, "FIFO empty flag unset after ticks: ", i);
         end
         else begin
            assertWeq_int(o_empty, o_empty_reg, "FIFO empty flag unset after ticks: ", i);
         end
      end
      @(negedge clk);
   end
   assertEeq(o_empty, 0, "FIFO empty flag unset not working!");

   while (!o_empty) begin
      @(negedge clk);
      i_rd_en  = 1'b1;
   end
   zero_input;
   #(3*`CLK_PERIOD) delta = 1;
   // Write N words and read back N words. Increment N
   for (k=0; k<FIFO_DEPTH; k=k+1) begin
      for (i=0; i<delta; i=i+1) begin
         @(negedge clk);
         i_data   = $urandom;
         i_wr_en  = 1'b1;
      end
      i_wr_en  = 1'b0;
      for (i=0; i<delta; i=i+1) begin
         @(negedge clk);
         i_rd_en  = 1'b1;
      end
      i_rd_en  = 1'b0;
      for (j=0; j<maxWaitTicks; j=j+1) begin
         @(negedge clk);
      end
      assertEeq(o_empty, 1, "FIFO empty flag malfunction!");
      delta = delta +1;
   end

   zero_input;
   assertI("INFO! Task check_FIFO_emptyFlag - OK");
end
endtask


task check_FIFO_simultaneous_RW;
   integer i;
begin
   $display("simultaneous_RW - time: %d", $time);
   zero_input;

   ////////// STAGE 1 - starting point: FIFO empty
   // set default state - FIFO empty
   while (!o_empty) begin
      @(negedge clk);
      i_rd_en  = 1'b1;
   end
   zero_input;

   simultaneous_RW(1, 1, 0, "starting at empty");
   assertI("INFO! Task check_FIFO_simultaneous_RW: starting at FIFO empty - OK");

   ////////// STAGE 2 - starting point: FIFO half full/half empty
   // set default state - FIFO half full/half empty
   while (!o_empty) begin
      @(negedge clk);
      i_rd_en  = 1'b1;
   end
   zero_input;
   for (i=0; i<FIFO_DEPTH/2; i=i+1) begin
      @(negedge clk);
      i_data      = $urandom;
      i_wr_en     = 1'b1;
   end

   simultaneous_RW(0, 0, 0, "starting at half full/half empty");
   assertI("INFO! Task check_FIFO_simultaneous_RW: starting at FIFO half full/half empty - OK");

   ////////// STAGE 3 - starting point: FIFO almost full
   // set default state - FIFO almost full (full -1 sample)
   while (!o_full) begin
      @(negedge clk);
      i_data   = $urandom;
      i_wr_en  = 1'b1;
   end
   zero_input;
   @(negedge clk) i_rd_en = 1'b1;
   @(negedge clk) i_rd_en = 1'b0;
   
   simultaneous_RW(0, 0, 0, "starting at almost full");
   assertI("INFO! Task check_FIFO_simultaneous_RW: starting at FIFO almost full - OK");

   ////////// STAGE 4 - starting point: FIFO almost empty
   // set default state - FIFO almost empty (empty +1 sample)
   while (!o_empty) begin
      @(negedge clk);
      i_rd_en  = 1'b1;
   end
   zero_input;
   @(negedge clk) i_data   = $urandom;
   i_wr_en  = 1'b1;
   @(negedge clk) zero_input;

   simultaneous_RW(0, 0, 0, "starting at almost empty");
   assertI("INFO! Task check_FIFO_simultaneous_RW: starting at FIFO almost empty - OK");

   ////////// STAGE 5 - starting point: FIFO full
   // set default state - FIFO full
   while (!o_full) begin
      @(negedge clk);
      i_data   = $urandom;
      i_wr_en  = 1'b1;
   end
   zero_input;
   
   simultaneous_RW(0, 0, 1, "starting at full");
   assertI("INFO! Task check_FIFO_simultaneous_RW: starting at FIFO full - OK");

end
endtask


task simultaneous_RW;
   input compare_iodata;
   input expected_empty_flag;
   input expected_full_flag;
   input [964*8-1:0] input_string;
   reg [1024*8-1:0] empty_string;
   reg [1024*8-1:0] full_string;
   reg [1024*8-1:0] iodata_string;
   integer offset;
   integer i;
begin
   empty_string   = {"Wrong FIFO empty flag during simultaneous R/W operation - ", input_string};
   full_string    = {"Wrong FIFO full flag during simultaneous R/W operation - ", input_string};
   iodata_string  = {"FIFO odata doesn't match idata - ", input_string};

   // simultaneously write & read FIFO
   @(negedge clk);
   offset         = FIFO_DPRAM.wr_ptr;
   for (i=0; i<FIFO_DEPTH*4; i=i+1) begin
      i_data   = $urandom;
      data[(i+offset)%FIFO_DEPTH]  = i_data;
      i_wr_en  = 1'b1;
      i_rd_en  = 1'b1;
      @(negedge clk);
      assertEeq(o_empty, expected_empty_flag, empty_string);
      assertEeq(o_full, expected_full_flag, full_string);
      if (compare_iodata) begin
         assertEeq(o_data, i_data, iodata_string);
      end

      if (i%FIFO_DEPTH == FIFO_DEPTH-2) begin
         data_test_en = 1;
      end
      else begin
         data_test_en = 0;
      end
   end
   zero_input;
end
endtask


always @(posedge clk) begin
   #(`CLK_PERIOD/10) if (data_test_en) begin
      for (ii=0; ii<FIFO_DEPTH; ii=ii+1) begin
         //$display("time: %d: ii = %d, data = %d, memory = %d", $time, ii, data[ii], FIFO_DPRAM.DualPortRAM.memory[ii]);
         assertEeq(data[ii], FIFO_DPRAM.DualPortRAM.memory[ii], "FIFO lost data");
      end
   end
end

endmodule
