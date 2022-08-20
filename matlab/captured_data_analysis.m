clear;
close all;
clc;
%% read data
fileID = fopen('sensor_data.bin');
data_input = fread(fileID, 'uint8', 'ieee-be');
%% extract processed data
fs = 40e6;
ts = 1 / ts;
header_index_temp1 = find(data_input == 170);
header_start = strfind(data_input', [170, 170, 170, 170]);
footer_start = strfind(data_input', [85, 85, 85, 85]);
valid_packet_index = find(header_start + 16 == footer_start);
valid_header_end = header_start(valid_packet_index)' +3;
header_end_diff = diff(valid_header_end);
time_stamp = ts * get_data_slice(data_input, valid_header_end + 1, 4);
time_stamp_diff = diff(time_stamp);
c_value = get_data_slice(data_input, valid_header_end + 5, 6);
d_value = get_data_slice(data_input, valid_header_end + 10, 6);
s_value = d_value / c_value;
plot(s_value, time_stamp);
%%
