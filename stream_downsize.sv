// SPDX-FileCopyrightText: 2024 Egor Guslyancev <electromagneticcyclone@disroot.org>
//
// SPDX-License-Identifier: Apache-2.0

module stream_downsize #(
  parameter T_DATA_WIDTH  = 1,
            T_DATA_RATIO  = 2,
            T_WIDTH_RATIO = $clog2(T_DATA_RATIO)
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

  // Nothing here yet

endmodule
