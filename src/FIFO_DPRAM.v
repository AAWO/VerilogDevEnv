// File Name : Defines.vh
// Author    : Andrzej Wojciechowski (AAWO)
// Copyright : Andrzej Wojciechowski (AAWO)
// --------------------------------------------
`timescale 1ns / 1ps
`include "Defines.vh"

module FIFO_DPRAM #(
   parameter      DATA_W      = 16,
   parameter      FIFO_DEPTH  = 256
)(
   input  wire    clk,
   input  wire    rst,

   input  wire    i_wr_en,
   input  wire    i_rd_en,

   output wire    o_empty,
   output wire    o_full,

   input  wire[DATA_W-1:0] i_data,
   output wire[DATA_W-1:0] o_data
);

localparam ADDR_W = $clog2(FIFO_DEPTH);
reg[ADDR_W-1:0] wr_ptr;
reg[ADDR_W-1:0] rd_ptr;
reg looped;
reg empty;
reg full;
wire wr_mask;

assign o_empty = empty;
assign o_full  = full;
assign wr_mask = !looped || (rd_ptr != wr_ptr) || (i_rd_en && i_wr_en);

always @(posedge clk or negedge rst) begin
   if (!rst) begin
      wr_ptr            <= {ADDR_W{1'b0}};
      rd_ptr            <= {ADDR_W{1'b0}};
   end
   else begin
      if (i_rd_en) begin
         if (looped || (rd_ptr != wr_ptr) || i_wr_en) begin
            if (rd_ptr == FIFO_DEPTH -1) begin
               rd_ptr   <= {ADDR_W{1'b0}};
            end
            else begin
               rd_ptr   <= rd_ptr +1'b1;
            end
         end
      end

      if (i_wr_en) begin
         if (!looped || (rd_ptr != wr_ptr) || i_rd_en) begin
            if (wr_ptr == FIFO_DEPTH -1) begin
               wr_ptr   <= {ADDR_W{1'b0}};
            end
            else begin
               wr_ptr   <= wr_ptr +1'b1;
            end
         end
      end
   end
end


always @(posedge clk or negedge rst) begin
   if (!rst) begin
      looped      <= 1'b0;
   end
   else begin
      // simultaneous read/write
      if (i_wr_en && i_rd_en) begin
         looped   <= looped;
      end
      else if (i_wr_en && (wr_ptr == FIFO_DEPTH -1) &&
               (!looped || (rd_ptr != wr_ptr) || i_rd_en)) begin
         looped   <= 1'b1;
      end
      else if (i_rd_en && (rd_ptr == FIFO_DEPTH -1) &&
               (looped || (rd_ptr != wr_ptr) || i_wr_en)) begin
         looped   <= 1'b0;
      end
      else begin
         looped   <= looped;
      end
   end
end


always @(posedge clk or negedge rst) begin
   if (!rst) begin
      full     <= 1'b0;
   end
   else begin
      if (i_wr_en && (wr_ptr == rd_ptr - 1'b1)) begin
         if (i_rd_en)            full  <= 1'b0;
         else                    full  <= 1'b1;
      end
      else if (i_rd_en && (wr_ptr == rd_ptr)) begin
         if (i_wr_en && looped)  full  <= 1'b1;
         else                    full  <= 1'b0;
      end
      else if (looped && (wr_ptr == rd_ptr)) begin
         full  <= 1'b1;
      end
      else begin
         full  <= 1'b0;
      end
   end
end


always @(posedge clk or negedge rst) begin
   if (!rst) begin
      empty    <= 1'b1;
   end
   else begin
      if (i_rd_en && (rd_ptr == wr_ptr - 1'b1)) begin
         if (i_wr_en)            empty <= 1'b0;
         else                    empty <= 1'b1;
      end
      else if (i_wr_en && (wr_ptr == rd_ptr)) begin
         if (i_rd_en && !looped) empty <= 1'b1;
         else                    empty <= 1'b0;
      end
      else if (!looped && (wr_ptr == rd_ptr)) begin
         empty <= 1'b1;
      end
      else begin
         empty <= 1'b0;
      end
   end
end


DualPortRAM #(
   .DATA_W(DATA_W),
   .ADDR_W(ADDR_W),
   .MEM_SIZE(FIFO_DEPTH))
DualPortRAM (
   .clk(clk),
   .rst(rst),
   .i_wr_en(i_wr_en && wr_mask),
   .i_rd_en(i_rd_en),
   .i_wr_addr(wr_ptr),
   .i_rd_addr(rd_ptr),
   .i_data(i_data),
   .o_data(o_data)
);

endmodule
