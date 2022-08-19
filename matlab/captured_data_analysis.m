clear;
close all;
clc;
%%
fileID = fopen('sensor_data.bin');
data_input = fread(fileID,'uint8','ieee-be');
%%
header_index_temp1 = find(data_input == 170);
header_start = strfind( data_input', [170,170,170,170]);
header_end = header_start' +3;
header_end_diff = diff(header_end);
time_stamp = 2^24*data_input(header_end+4)+2^16*data_input(header_end+3)+2^8*data_input(header_end+2)+data_input(header_end+1);
time_stamp_diff = diff(time_stamp); 
