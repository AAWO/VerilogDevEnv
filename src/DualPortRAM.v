// File Name : Defines.vh
// Author    : Andrzej Wojciechowski (AAWO)
// Copyright : Andrzej Wojciechowski (AAWO)
// --------------------------------------------
`timescale 1ns / 1ps
`include "Defines.vh"

module DualPortRAM #(
   parameter      DATA_W   = 16,
   parameter      ADDR_W   = 8,
   parameter      MEM_SIZE = 256
)(
   input  wire    clk,
   input  wire    rst,

   input  wire    i_wr_en,
   input  wire    i_rd_en,

   input  wire[ADDR_W-1:0] i_wr_addr,
   input  wire[ADDR_W-1:0] i_rd_addr,

   input  wire[DATA_W-1:0] i_data,
   output wire[DATA_W-1:0] o_data
);

(* ram_style = "auto" *) reg [DATA_W-1:0] memory [0:MEM_SIZE-1];
reg [ADDR_W-1:0] rd_addr_reg;
integer i;

assign o_data = memory[rd_addr_reg];

always @(posedge clk or negedge rst) begin
   if (!rst) begin
      for (i=0; i<MEM_SIZE; i=i+1) begin
         memory[i]      <= {DATA_W{1'b0}};
      end
   end
   else if (i_wr_en) begin
      memory[i_wr_addr] <= i_data;
   end
end

always @(posedge clk or negedge rst) begin
   if (!rst) begin
      rd_addr_reg <= {ADDR_W{1'b0}};
   end
   else if (i_rd_en) begin
      rd_addr_reg <= i_rd_addr;
   end
end

endmodule
