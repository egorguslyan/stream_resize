// SPDX-FileCopyrightText: 2024 Egor Guslyancev <electromagneticcyclone@disroot.org>
//
// SPDX-License-Identifier: Apache-2.0

module stream_upsize #(
  parameter T_DATA_WIDTH  = 1,
            T_DATA_RATIO  = 2,
            T_WIDTH_RATIO = $clog2(T_DATA_RATIO)
)(
  input  logic                    clk,
  input  logic                    rst_n,

  input  logic [T_DATA_WIDTH-1:0] s_data_i,
  input  logic                    s_last_i,
  input  logic                    s_valid_i,
  output logic                    s_ready_o,

  output logic [T_DATA_WIDTH-1:0] m_data_o [T_DATA_RATIO-1:0],
  output logic [T_DATA_RATIO-1:0] m_keep_o,
  output logic                    m_last_o,
  output logic                    m_valid_o,
  input  logic                    m_ready_i
);

  logic [T_WIDTH_RATIO:0] keep_counter;
  logic [T_WIDTH_RATIO:0] keep_counter_inc;
  logic last_r;

  function [T_DATA_RATIO-1:0] expand_bits;
    input [T_WIDTH_RATIO:0] value;
    integer i;
    begin
      expand_bits = 0;
      for (i = 0; (i < value) && (i < T_DATA_RATIO); i = i + 1)
        expand_bits[i] = 1'b1;
    end
  endfunction

  always_comb begin
    keep_counter_inc = keep_counter + 1;
    s_ready_o = ~m_valid_o;
  end

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      m_valid_o <= 0;
      keep_counter <= 0;
    end
    if (s_ready_o && s_valid_i) begin
      keep_counter <= keep_counter_inc;
      m_valid_o <= (keep_counter_inc == T_DATA_RATIO) || s_last_i;
      m_last_o <= s_last_i;
      m_keep_o <= expand_bits(keep_counter_inc);
      m_data_o[keep_counter] <= s_data_i;
    end else if (m_ready_i) begin
      m_valid_o <= 0;
      keep_counter <= 0;
    end
  end

endmodule
