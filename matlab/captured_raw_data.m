clear;
close all;
clc;
%% read data
fileID = fopen('sensor_data.bin');
data_input = fread(fileID, 'uint8', 'ieee-be');
%% extract processed data
fs = 40e6;
ts = 1 / fs;
header_start = strfind(data_input', [170, 170, 170, 170])';
footer_start = strfind(data_input', [85, 85, 85, 85])';

if (header_start(1) > footer_start(1))
    footer_start = footer_start(2:end);
end

max_length = min(length(header_start), length(footer_start));

valid_packet_index = find(header_start(1:max_length) + 24 == footer_start(1:max_length));

valid_header_end = header_start(2:end-2) +5;
header_end_diff = diff(valid_header_end);
time_stamp = ts.*get_data_slice(data_input, valid_header_end + 1, 6);
sensor_raw_data = zeros(length(valid_header_end),1024);
for i=1:length(valid_header_end)
   sensor_raw_data(i,(1:2:1024)) = get_data_slice(data_input,(1:2:1024)+valid_header_end(i)+6,2);
   sensor_raw_data(i,(2:2:1024)) = get_data_slice(data_input,(1:2:1024)+valid_header_end(i)+8,2);
end



%%