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


module s15611_driver
  #(
     parameter NUMBER_OF_PIXEL = 128,
     parameter SI_WIDTH_NCLK = 4,
     parameter SENSOR_CLK_WIDTH_NCLK = 100,
     parameter INITIAL_DELAY_NCLK = 18*SENSOR_CLK_WIDTH_NCLK,
     parameter TS_NCLK = 35
   )
   (
     input master_clock,
     input resetn,
	 // sensor interface
     output s15611_mclk,
     output s15611_mst,
     output s15611_cs,
     input s15611_miso,
     output s15611_mosi,
     output s15611_sclk,
     output s15611_rstb,
     input s15611_sync,
     input s15611_pclk,
     input [11:0] s15611_data,
	 // output data
     output [11:0] data_out,
     output [9:0] data_index,
     output data_valid
   );

  reg [7:0] clk_counter;
  reg [15:0] pixel_counter;
  reg [31:0] si_counter;
  reg initial_interval;

  always_ff @(posedge master_clock)
  begin
    if(clk_counter >= SENSOR_CLK_WIDTH_NCLK-1)
    begin
      cjmcu1401_clk = ~cjmcu1401_clk;
      clk_counter <= 8'd0;
    end
    else
    begin
      clk_counter = clk_counter +1;
      if((clk_counter == TS_NCLK) && (initial_interval == 0))
      begin
        sample_capture_trigger <= 1'b1;
        pixel_counter = pixel_counter + 1;
      end
      else
      begin
        sample_capture_trigger <= 1'b0;
      end
    end
    if((32'd6 <= si_counter) && (si_counter <= (32'd6 + SI_WIDTH_NCLK)))
    begin
      si_counter = si_counter + 1;
      cjmcu1401_si = 1'b1;
      initial_interval = 1'b1;
    end
    else if(si_counter >= INITIAL_DELAY_NCLK + NUMBER_OF_PIXEL * SENSOR_CLK_WIDTH_NCLK)
      si_counter <= 32'd0;
    else
    begin
      cjmcu1401_si = 1'b0;
      si_counter = si_counter + 1;
    end
    if(si_counter >= INITIAL_DELAY_NCLK )
      initial_interval = 1'b0;
  end
  assign pixel_counter_out = pixel_counter;
endmodule
