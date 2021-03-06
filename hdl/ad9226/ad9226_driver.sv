`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//------------------
//-___           ___
//|   |         |   |
//|   |         |   |
//|   |         |   |
//|   |_________|   |
//|                 |
//|    H128B717     |
//|    _________    |
//|   |         |   |
//|   |         |   |
//|   |         |   |
//|___|         |___|
//-------------------
// Engineer: HosseinBehshti
//////////////////////////////////////////////////////////////////////////////////

module ad9226_driver(
    input master_clock,
    input reset,
    (* IOB="true" *)
    input ad9226_otr,
    (* IOB="true" *)
    input [11:0] ad9226_data,
    output reg [11:0] adc_data,
    output reg adc_data_valid,
    output reg adc_data_otr,
    output reg ad9226_clk
  );

  reg ad9226_clk_temp;
  reg ad9226_otr_temp;

  always @(posedge master_clock)
  begin
    // create clock
    ad9226_clk_temp = ~ad9226_clk_temp;
    ad9226_clk <= ad9226_clk_temp;
    adc_data = ad9226_data;
    ad9226_otr_temp = ad9226_otr;
    adc_data_valid = ~ad9226_otr_temp & ad9226_clk_temp;
    adc_data_otr = ad9226_otr_temp;
  end

endmodule
