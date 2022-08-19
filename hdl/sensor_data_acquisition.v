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


module sensor_data_acquisition
  (
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME master_clock, FREQ_HZ 40000000" *)
    input master_clock,
    input resetn,
    input send_raw_data,
    input [15:0] number_of_packet,
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
    // axis_data
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF data,  FREQ_HZ 40000000" *)
    input data_tready,
    output reg [31:0] data_tdata,
    output reg data_tlast,
    output reg data_tvalid,
    // debug port
    output reg [3:0] dbg_axis_state,
    output [3:0] dbg_sensor_state,
    output [11:0] dbg_sensor_raw_data,
    output [11:0] dbg_sensor_data,
    output [9:0] dbg_sensor_index,
    output dbg_sensor_valid
  );

  genvar i;
  wire [11:0] sensor_data;
  wire [9:0] sensor_data_index;
  wire  sensor_data_valid;
  reg [11:0] sensor_data_reg[5:0];
  reg [9:0] sensor_data_index_reg[5:0];
  reg sensor_data_valid_reg[5:0];
  reg [31:0] time_counter;
  localparam [31:0] HEADER_VALUE = 32'hAAAAAAAA;
  localparam [31:0] FOOTER_VALUE = 32'h55555555;
  localparam [31:0] TLAST_VALUE = 32'hBBBBBBBB;
  localparam [3:0]  IDLE = 0, HEADER = 1, TIME_STAMP = 2, DATA_ACQ1 = 3, DATA_ACQ2 = 4, RAW_DATA = 5, FOOTER = 6, TLAST_ASSERT = 7;
  reg [3:0] axis_state = IDLE;
  reg [31:0] raw_data_data;
  reg [95:0] processed_data;
  reg [7:0] data_counter;
  reg [15:0] packet_counter;
  reg [24:0] y_value;
  reg [47:0] c_acc;
  reg [47:0] d_acc;

  s15611_driver s15611_driver_inst
                (
                  .master_clock(master_clock),
                  .resetn(resetn),
                  // sensor interface
                  .s15611_mclk(s15611_mclk),
                  .s15611_mst(s15611_mst),
                  .s15611_cs(s15611_cs),
                  .s15611_miso(s15611_miso),
                  .s15611_mosi(s15611_mosi),
                  .s15611_sclk(s15611_sclk),
                  .s15611_rstb(s15611_rstb),
                  .s15611_sync(s15611_sync),
                  .s15611_pclk(s15611_pclk),
                  .s15611_data(s15611_data),
                  // output data
                  .data_out(sensor_data),
                  .data_index(sensor_data_index),
                  .data_valid(sensor_data_valid),
                  // debug port
                  .dbg_state(dbg_sensor_state),
                  .dbg_sensor_raw_data(dbg_sensor_raw_data),
                  .dbg_sensor_data(dbg_sensor_data),
                  .dbg_sensor_index(dbg_sensor_index),
                  .dbg_sensor_valid(dbg_sensor_valid)
                );

  always @(posedge master_clock)
  begin
    if (resetn)
    begin
      time_counter <= time_counter + 1;
      sensor_data_reg[0] <= sensor_data;
      sensor_data_index_reg[0] <= sensor_data_index;
      sensor_data_valid_reg[0] <= sensor_data_valid;
    end
    else
    begin
      time_counter <= 0;
    end
  end

  generate
    for (i = 0; i < 5; i = i+1)
    begin: shift_reg
      always @(posedge master_clock)
      begin
        sensor_data_reg[i+1] <= sensor_data_reg[i];
        sensor_data_index_reg[i+1] <= sensor_data_index_reg[i];
        sensor_data_valid_reg[i+1] <= sensor_data_valid_reg[i];
      end
    end
  endgenerate

  // prepare data packet
  always @(posedge master_clock)
  begin
    dbg_axis_state <= axis_state;
    data_tdata <= 0;
    data_tvalid <= 0;
    data_tlast <= 0;
    y_value <= 0;
    c_acc <= 0;
    d_acc <= 0;
    data_counter <= 0;
    case (axis_state)
      IDLE:
      begin
        if ((sensor_data_valid == 1) && (sensor_data_valid_reg[0] == 0))
        begin
          axis_state <= HEADER;
        end
        else
        begin
          axis_state <= IDLE;
        end
      end

      HEADER:
      begin
        data_tdata <= HEADER_VALUE;
        data_tvalid <= 1;
        axis_state <= TIME_STAMP;
      end

      TIME_STAMP:
      begin
        data_tdata <= time_counter;
        data_tvalid <= 1;
        if (send_raw_data)
        begin
          axis_state <= RAW_DATA;
        end
        else
        begin
          axis_state <= DATA_ACQ1;
        end
      end

      DATA_ACQ1:
      begin
        y_value <= sensor_data_reg[3]*sensor_data_reg[3];
        c_acc <= c_acc + y_value;
        d_acc <= d_acc + y_value*sensor_data_index_reg[3];
        // debug data link
        processed_data <= {d_acc, c_acc};
        if (sensor_data_index_reg[3] < 1023)
        begin
          axis_state <= DATA_ACQ1;
        end
        else if (sensor_data_index_reg[3] == 1023)
        begin
          axis_state <= DATA_ACQ2;
        end
      end

      DATA_ACQ2:
      begin
        if (data_counter < 3)
        begin
          data_counter <= data_counter + 1;
          data_tvalid <= 1;
          axis_state <= DATA_ACQ2;
        end
        else
        begin
          axis_state <= FOOTER;
        end
        case (data_counter)
          0:
            data_tdata <= processed_data[(0+1)*32-1:0*32];
          1:
            data_tdata <= processed_data[(1+1)*32-1:1*32];
          2:
            data_tdata <= processed_data[(2+1)*32-1:2*32];
          default:
            data_tdata <= 32'hEEEEEEEE;
        endcase
      end

      RAW_DATA:
      begin
        if (sensor_data_index_reg[3] < 1023)
        begin
          axis_state <= RAW_DATA;
        end
        else if (sensor_data_index_reg[3] == 1023)
        begin
          axis_state <= FOOTER;
        end
        if (sensor_data_index_reg[3][0])
        begin
          data_tdata <= {4'd0, sensor_data_reg[4],4'd0, sensor_data_reg[3]};
          data_tvalid <= 1;
        end
        else
        begin
          data_tvalid <= 0;
        end
      end

      FOOTER:
      begin
        data_tdata <= FOOTER_VALUE;
        data_tvalid <= 1;
        if (packet_counter < number_of_packet)
        begin
          packet_counter <= packet_counter + 1;
          axis_state <= IDLE;
        end
        else
        begin
          packet_counter <= 0;
          axis_state <= TLAST_ASSERT;
        end
      end

      TLAST_ASSERT:
      begin
        data_tdata <= TLAST_VALUE;
        data_tvalid <= 1;
        data_tlast <= 1;
        axis_state <= IDLE;
      end
    endcase
  end
endmodule
