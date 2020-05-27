// -----------------------------------------------------------------------------
// File Name   : AssertLib.v
// Author      : Andrzej Wojciechowski (AAWO)
// Copyright   : Andrzej Wojciechowski (AAWO)
// Description : Assertion library. Created to bypass Iverilog's lack of
//               support for immediate assertions
// -----------------------------------------------------------------------------

// Assert Equal
task assertEeq;
   input integer data_a;
   input integer data_b;
   input [1024*8-1:0] info_string;
begin
   if (data_a !== data_b) begin
      `ifdef IVERILOG
         $display("ERROR! %0s", info_string);
         $finish_and_return(1);
      `else
         assert(data_a == data_b) else $error("ERROR! %0s", info_string);
      `endif
   end
end
endtask

task assertWeq;
   input integer data_a;
   input integer data_b;
   input [1024*8-1:0] info_string;
begin
   if (data_a !== data_b) begin
      `ifdef IVERILOG
         $display("WARNING! %0s", info_string);
      `else
         assert(data_a == data_b) else $warning("WARNING! %0s", info_string);
      `endif
   end
end
endtask

task assertIeq;
   input integer data_a;
   input integer data_b;
   input [1024*8-1:0] info_string;
begin
   if (data_a !== data_b) begin
      `ifdef IVERILOG
         $display("INFO! %0s", info_string);
      `else
         assert(data_a == data_b) else $info("INFO! %0s", info_string);
      `endif
   end
end
endtask


// Assert Less Than
task assertElt;
   input integer data_a;
   input integer data_b;
   input [1024*8-1:0] info_string;
begin
   if (data_a >= data_b) begin
      `ifdef IVERILOG
         $display("ERROR! %0s", info_string);
         $finish_and_return(1);
      `else
         assert(data_a < data_b) else $error("ERROR! %0s", info_string);
      `endif
   end
end
endtask


// Assert Less Equal
task assertEle;
   input integer data_a;
   input integer data_b;
   input [1024*8-1:0] info_string;
begin
   if (data_a > data_b) begin
      `ifdef IVERILOG
         $display("ERROR! %0s", info_string);
         $finish_and_return(1);
      `else
         assert(data_a <= data_b) else $error("ERROR! %0s", info_string);
      `endif
   end
end
endtask


// Assert Greater Than
task assertEgt;
   input integer data_a;
   input integer data_b;
   input [1024*8-1:0] info_string;
begin
   if (data_a <= data_b) begin
      `ifdef IVERILOG
         $display("ERROR! %0s", info_string);
         $finish_and_return(1);
      `else
         assert(data_a > data_b) else $error("ERROR! %0s", info_string);
      `endif
   end
end
endtask


// Assert Greater Equal
task assertEge;
   input integer data_a;
   input integer data_b;
   input [1024*8-1:0] info_string;
begin
   if (data_a < data_b) begin
      `ifdef IVERILOG
         $display("ERROR! %0s", info_string);
         $finish_and_return(1);
      `else
         assert(data_a >= data_b) else $error("ERROR! %0s", info_string);
      `endif
   end
end
endtask


// Assert Equal with integer print
task assertWeq_int;
   input integer data_a;
   input integer data_b;
   input [1024*8-1:0] info_string;
   input integer info_int;
begin
   if (data_a !== data_b) begin
      `ifdef IVERILOG
         $display("WARNING! %0s %d", info_string, info_int);
      `else
         assert(data_a == data_b) else $warning("WARNING! %0s %d", info_string, info_int);
      `endif
   end
end
endtask


task assertIeq_int;
   input integer data_a;
   input integer data_b;
   input [1024*8-1:0] info_string;
   input integer info_int;
begin
   if (data_a !== data_b) begin
      `ifdef IVERILOG
         $display("INFO! %0s %d", info_string, info_int);
      `else
         assert(data_a == data_b) else $info("INFO! %0s %d", info_string, info_int);
      `endif
   end
end
endtask


// Assert Zero
task assertEzero;
   input integer data_a;
   input [1024*8-1:0] info_string;
begin
   assertEeq(data_a, 0, info_string);
end
endtask


// Assert Info
task assertI;
   input [1024*8-1:0] info_string;
begin
   `ifdef IVERILOG
      $display("INFO! %0s", info_string);
   `else
      $info("INFO! %0s", info_string);
   `endif
end
endtask

