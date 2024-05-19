// SPDX-FileCopyrightText: 2024 Egor Guslyancev <electromagneticcyclone@disroot.org>
//
// SPDX-License-Identifier: Apache-2.0

module stream_downsize #(
  parameter T_DATA_WIDTH  = 1,
            T_DATA_RATIO  = 2,
            FIFO_SIZE     = 2
)(
  input  logic                    clk,
  input  logic                    rst_n,

  input  logic [T_DATA_WIDTH-1:0] s_data_i [T_DATA_RATIO-1:0],
  input  logic                    s_last_i,
  input  logic                    s_valid_i,
  output logic                    s_ready_o,

  output logic [T_DATA_WIDTH-1:0] m_data_o,
  output logic                    m_last_o,
  output logic                    m_valid_o,
  input  logic                    m_ready_i
);

  logic push_ready;
  logic pop_ready;
  logic m_last;

  logic [T_DATA_WIDTH:0]   fifo_out [T_DATA_RATIO-1:0];
  logic [T_DATA_RATIO-1:0] fifo_full;
  logic [T_DATA_RATIO-1:0] fifo_empty;
  logic [T_DATA_RATIO-1:0] fifo_addr;
  logic [T_DATA_RATIO-1:0] next_fifo_addr;

  generate
    genvar i;
    for (i = 0; i < T_DATA_RATIO; i = i + 1) begin: generate_fifo
      fifo #(
        .DATA_WIDTH (T_DATA_WIDTH + 1),
        .FIFO_SIZE  (FIFO_SIZE)
      ) node (
        .clk   (clk),
        .rst_n (rst_n),

        .in_data ({s_last_i, s_data_i[i]}),
        .push    (push_ready),
        .full    (fifo_full[i]),
        
        .out_data (fifo_out[i]),
        .pop      (pop_ready & (i == fifo_addr)),
        .empty    (fifo_empty[i])
      );
    end
  endgenerate

  always_comb begin
    s_ready_o      = |fifo_full;
    m_valid_o      = ~(&fifo_empty);
    m_last_o       = m_last & &fifo_addr;
    
    push_ready = s_ready_o & s_valid_i;
    pop_ready  = m_ready_i & m_valid_o;

    next_fifo_addr = fifo_addr + '1;
  end
  
  always_ff @(posedge clk) begin
    if (~rst_n) begin
      fifo_addr <= '0;
    end else begin
      // if (push_ready) begin
      // end
      if (pop_ready) begin
        {m_last, m_data_o} <= fifo_out[fifo_addr];
        fifo_addr <= next_fifo_addr;
      end
    end
  end

endmodule
