`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: HosseinBehshti
//
// Create Date: 06/05/2021 08:08:58 PM
// Design Name:
// Module Name: cjmcu1401_driver
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


module cjmcu1401_driver(
    input master_clock,
    (* IOB="true" *)
    output reg cjmcu1401_si,
    (* IOB="true" *)
    output reg cjmcu1401_clk
  );

  reg [7:0] clk_counter;
  reg [31:0] si_counter;
  reg cjmcu1401_clk_temp;

  always @(posedge master_clock)
  begin
    // create clock
    if(clk_counter == 8'd99)
    begin
      cjmcu1401_clk = ~cjmcu1401_clk;
      clk_counter <= 8'd0;
    end
    else
    begin
      clk_counter = clk_counter +1;
    end
    // create SI signal
    if(si_counter == 32'd12849)
    begin
      si_counter = 32'd0;
      cjmcu1401_si = 1'b1;
    end
    else
    begin
      cjmcu1401_si = 1'b0;
      si_counter = si_counter +1;

    end
  end
endmodule
