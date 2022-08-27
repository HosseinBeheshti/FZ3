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
     parameter MCLK_MHZ = 40,
     parameter NUMBER_OF_PIXEL = 1024,
     parameter CDC_REG_LENGTH = 4
   )
   (
     input master_clock,
     input resetn,
     input [31:0] master_start_pulse_period,
     input [31:0] master_start_pulse_high_period,
     // sensor interface
     output s15611_mclk,
     output logic s15611_mst,
     output s15611_cs,
     input s15611_miso,
     output s15611_mosi,
     output s15611_sclk,
     output s15611_rstb,
     input s15611_sync,
     input s15611_pclk,
     input [11:0] s15611_data,
     // output data
     output logic [11:0] data_out,
     output logic [9:0] data_index,
     output logic data_valid,
     // debug port
     output logic [3:0] dbg_state,
     output logic [11:0] dbg_sensor_raw_data,
     output logic [11:0] dbg_sensor_data,
     output logic [9:0] dbg_sensor_index,
     output logic dbg_sensor_valid
   );

  genvar i;
  logic sensor_clock;
  logic [31:0] mclk_counter;
  logic data_capture_triger;
  logic [15:0] pixel_counter;
  enum logic [3:0] {BLANKING_PERIOD, SYNC_CLK1, SYNC_CLK2, CAPTURE_DATA} state;
  (* ASYNC_REG="true" *)
  logic [11:0] data_in_temp[CDC_REG_LENGTH:0];
  (* ASYNC_REG="true" *)
  logic [11:0] data_out_temp[CDC_REG_LENGTH:0];
  (* ASYNC_REG="true" *)
  logic [9:0] data_index_temp[CDC_REG_LENGTH:0];
  (* ASYNC_REG="true" *)
  logic data_valid_temp[CDC_REG_LENGTH:0];
  // TODO: implement spi controller interface
  assign s15611_cs = 1;
  assign s15611_mosi = 0;
  assign s15611_sclk = 0;
  assign s15611_rstb = 0;

  // drive sensor
  assign s15611_mclk = master_clock;
  always_ff @(posedge master_clock)
  begin
    if(mclk_counter >= master_start_pulse_period-1)
    begin
      mclk_counter <= 0;
    end
    else
    begin
      mclk_counter <= mclk_counter + 1;
    end

    if (mclk_counter <=  master_start_pulse_high_period-1)
    begin
      s15611_mst <= 1;
    end
    else
    begin
      s15611_mst <= 0;
    end
  end

  // capture data
  always_ff @(posedge s15611_pclk)
  begin
    dbg_state <= state;
    data_in_temp[0] <= s15611_data;
    data_out_temp[0] <= 0;
    data_valid_temp[0] <= 0;
    case (state)
      BLANKING_PERIOD :
      begin
        if (s15611_sync)
        begin
          state <= BLANKING_PERIOD;
        end
        else
        begin
          state <= SYNC_CLK1;
        end
      end
      SYNC_CLK1 :
      begin
        state <= SYNC_CLK2;
      end
      SYNC_CLK2 :
      begin
        state <= CAPTURE_DATA;
        data_out_temp[0] <= s15611_data;
      end
      CAPTURE_DATA :
      begin
        if (pixel_counter <= NUMBER_OF_PIXEL-1)
        begin
          state <= CAPTURE_DATA;
          pixel_counter <= pixel_counter + 1;
          data_out_temp[0] <= s15611_data;
          data_index_temp[0] <= pixel_counter + 1;
          data_valid_temp[0] <= 1;
        end
        else
        begin
          pixel_counter <= 0;
          state <= BLANKING_PERIOD;
        end
      end
    endcase
  end

  // CDC data
  generate
    for (i = 0; i < CDC_REG_LENGTH; i++)
    begin: cdc_reg_delay
      always_ff @(posedge master_clock)
      begin
        data_in_temp[i+1] <= data_in_temp[i];
        data_out_temp[i+1] <= data_out_temp[i];
        data_index_temp[i+1] <= data_index_temp[i];
        data_valid_temp[i+1] <= data_valid_temp[i];
      end
    end
  endgenerate

  assign data_out = data_out_temp[CDC_REG_LENGTH];
  assign data_index = data_index_temp[CDC_REG_LENGTH];
  assign data_valid = data_valid_temp[CDC_REG_LENGTH];

  assign dbg_sensor_raw_data = data_in_temp[CDC_REG_LENGTH];
  assign dbg_sensor_data = data_out_temp[CDC_REG_LENGTH];
  assign dbg_sensor_index = data_index_temp[CDC_REG_LENGTH];
  assign dbg_sensor_valid = data_valid_temp[CDC_REG_LENGTH];

endmodule
