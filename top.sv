// SPDX-FileCopyrightText: 2024 Egor Guslyancev <electromagneticcyclone@disroot.org>
//
// SPDX-License-Identifier: Apache-2.0

module top #(
  parameter T_DATA_WIDTH = 32,
            T_DATA_RATIO = 3,
            T_WIDTH_RATIO = $clog2(T_DATA_RATIO)
)(
  input  clk,
  input  rst_n,

  input  [T_DATA_WIDTH-1:0] s_data      [T_DATA_RATIO-1:0],
  input                     s_last    [T_DATA_RATIO-1:0],
  input                     s_valid,
  output                    s_ready,

  output [T_DATA_WIDTH-1:0] upsized   [T_DATA_RATIO-1:0],
  output [T_WIDTH_RATIO:0]  u_keep,
  output                    u_last,
  output                    u_valid,
  input                     u_ready,

  output [T_DATA_WIDTH-1:0] downsized,
  output                    d_last,
  output                    d_valid
);

  assign d_valid = '0;
  
  stream_upsize #(
    .T_DATA_WIDTH (T_DATA_WIDTH),
    .T_DATA_RATIO (T_DATA_RATIO)
  ) upsizer (
    .clk   (clk),
    .rst_n (rst_n),

    .s_data_i  (s_data[0]),
    .s_last_i  (s_last[0]),
    .s_valid_i (s_valid),
    .s_ready_o (s_ready),

    .m_data_o  (upsized),
    .m_keep_o  (u_keep),
    .m_last_o  (u_last),
    .m_valid_o (u_valid),
    .m_ready_i (u_ready)
  );

endmodule