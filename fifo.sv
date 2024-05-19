// SPDX-FileCopyrightText: 2024 Egor Guslyancev <electromagneticcyclone@disroot.org>
//
// SPDX-License-Identifier: Apache-2.0

module fifo #(
  parameter DATA_WIDTH = 1,
            FIFO_SIZE  = 2,
            FIFO_WIDTH = $clog2(FIFO_SIZE)
)(
  input clk,
  input rst_n,

  input  logic [DATA_WIDTH-1:0] in_data,
  input  logic                  push,
  output logic                  full,

  output logic [DATA_WIDTH-1:0] out_data,
  input  logic                  pop,
  output logic                  empty
);

  logic [DATA_WIDTH-1:0] data [FIFO_WIDTH:0];

  logic [FIFO_WIDTH:0] pointer_start;
  logic [FIFO_WIDTH:0] pointer_end;
  logic [FIFO_WIDTH:0] next_pointer_start;
  logic [FIFO_WIDTH:0] next_pointer_end;
  
  function [FIFO_WIDTH:0] fifo_next;
    input [FIFO_WIDTH:0] fifo_curr;
    logic [FIFO_WIDTH:0] fifo_inc;
    begin
      fifo_inc  = fifo_curr + 1;
      fifo_next = (fifo_inc == FIFO_SIZE) ? '0 : fifo_inc;
    end
  endfunction

  always_comb begin
    next_pointer_start = fifo_next(pointer_start);
    next_pointer_end   = fifo_next(pointer_end);
    
    empty = (pointer_start == pointer_end);
    full  = (pointer_start == next_pointer_end);
  end
  
  always_ff @(posedge clk) begin
    if (~rst_n) begin
      pointer_start <= '0;
      pointer_end   <= '0;
    end else begin
      if (~full && push) begin
        data[pointer_end] <= in_data;
        pointer_end       <= next_pointer_end;
      end
      if (~empty && pop) begin
        out_data      <= data[pointer_start];
        pointer_start <= next_pointer_start;
      end
    end
  end

endmodule