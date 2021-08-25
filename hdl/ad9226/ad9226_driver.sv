`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: HosseinBehshti
//
// Create Date: 06/05/2021 08:08:58 PM
// Design Name:
// Module Name: ad9226_driver
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
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
    output reg ad9226_clk
  );

  always @(posedge master_clock)
  begin
    // create clock
    ad9226_clk = ~ad9226_clk;
    adc_data = ad9226_data;
    adc_data_valid = ~ad9226_otr;
  end

endmodule
