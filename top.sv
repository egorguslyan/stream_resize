// SPDX-FileCopyrightText: 2024 Egor Guslyancev <electromagneticcyclone@disroot.org>
//
// SPDX-License-Identifier: Apache-2.0

module top #(
  parameter T_DATA_WIDTH = 32,
            T_DATA_RATIO = 3,
            T_WIDTH_RATIO = $clog2(T_DATA_RATIO)
)(
  input  logic clk,
  input  logic rst_n,

  input  logic [T_DATA_WIDTH-1:0] s_data   [T_DATA_RATIO-1:0],
  input  logic                    s_last,
  input  logic                    s_valid,
  output logic                    s_ready,

  output logic [T_DATA_WIDTH-1:0] upsized  [T_DATA_RATIO-1:0],
  output logic [T_WIDTH_RATIO:0]  u_keep,
  output logic                    u_last,
  output logic                    u_valid,
  input  logic                    u_ready,

  output logic [T_DATA_WIDTH-1:0] downsized,
  output logic                    d_last,
  output logic                    d_valid,
  input  logic                    d_ready
);

  logic s_ready_d, s_ready_u;

  assign s_ready_o = s_ready_d & s_ready_u;
  
  stream_upsize #(
    .T_DATA_WIDTH (T_DATA_WIDTH),
    .T_DATA_RATIO (T_DATA_RATIO)
  ) upsizer (
    .clk   (clk),
    .rst_n (rst_n),

    .s_data_i  (s_data[0]),
    .s_last_i  (s_last),
    .s_valid_i (s_valid),
    .s_ready_o (s_ready_u),

    .m_data_o  (upsized),
    .m_keep_o  (u_keep),
    .m_last_o  (u_last),
    .m_valid_o (u_valid),
    .m_ready_i (u_ready)
  );
  
  stream_downsize #(
    .T_DATA_WIDTH (T_DATA_WIDTH),
    .T_DATA_RATIO (T_DATA_RATIO)
  ) downsizer (
    .clk   (clk),
    .rst_n (rst_n),

    .s_data_i  (s_data),
    .s_last_i  (s_last),
    .s_valid_i (s_valid),
    .s_ready_o (s_ready_d),

    .m_data_o  (downsized),
    .m_last_o  (d_last),
    .m_valid_o (d_valid),
    .m_ready_i (d_ready)
  );

endmodule