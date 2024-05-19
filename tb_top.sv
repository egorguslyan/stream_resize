// SPDX-FileCopyrightText: 2024 Egor Guslyancev <electromagneticcyclone@disroot.org>
//
// SPDX-License-Identifier: Apache-2.0

module tb_top;

  localparam CLK_PERIOD    = 1,
             T_DATA_WIDTH  = 32,
             T_DATA_RATIO  = 3,
             T_WIDTH_RATIO = $clog2(T_DATA_RATIO);

  logic ACLK;
  logic ARESETn;
  
  /* input  */ logic [T_DATA_WIDTH-1:0] s_data   [T_DATA_RATIO-1:0];
  /* input  */ logic                    s_last   [T_DATA_RATIO-1:0];
  /* input  */ logic                    s_valid;
  /* output */ logic                    s_ready;

  /* output */ logic [T_DATA_WIDTH-1:0] upsized  [T_DATA_RATIO-1:0];
  /* output */ logic [T_WIDTH_RATIO:0]  u_keep;
  /* output */ logic                    u_last;
  /* output */ logic                    u_valid;
  /* input  */ logic                    u_ready;

  /* output */ logic [T_DATA_WIDTH-1:0] downsized;
  /* output */ logic                    d_last;
  /* output */ logic                    d_valid;
  /* input  */ logic                    d_ready;


  initial begin
    ACLK <= 0;
    forever begin
      #(CLK_PERIOD/2) ACLK <= ~ACLK;
    end
  end

  initial begin
    ARESETn <= 0;
    #(10*CLK_PERIOD);
    @(negedge ACLK);
    ARESETn <= 1;
  end
  
  top #(
    .T_DATA_WIDTH (T_DATA_WIDTH),
    .T_DATA_RATIO (T_DATA_RATIO)
  ) dut (
    .clk   (ACLK),
    .rst_n (ARESETn),
    
    .s_data  (s_data),
    .s_last  (s_last),
    .s_valid (s_valid),
    .s_ready (s_ready),

    .upsized (upsized),
    .u_keep  (u_keep),
    .u_last  (u_last),
    .u_valid (u_valid),
    .u_ready (u_ready),

    .downsized (downsized),
    .d_last    (d_last),
    .d_valid   (d_valid),
    .d_ready   (d_ready)
  );

  initial begin
    u_ready   = 'b1;
    d_ready   = 'b1;
    s_valid   = 'b0;
    @(posedge ARESETn);
    @(posedge ACLK);
    s_valid   = 'b1;
    s_last[0] = 'b0;
    s_data[0] = 'h1;
    @(posedge ACLK);
    s_data[0] = 'h2;
    @(posedge ACLK);
    s_last[0] = 'b1;
    s_data[0] = 'h3;
    @(posedge ACLK);
    s_last[0] = 'b0;
    s_data[0] = 'ha;
    @(posedge ACLK);
    s_last[0] = 'b1;
    s_data[0] = 'hb;
    @(posedge ACLK);
    s_valid   = 'b0;
    forever $stop();
  end

endmodule