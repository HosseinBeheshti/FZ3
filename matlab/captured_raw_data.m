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

valid_header_end = header_start(2:end - 2) +5;
header_end_diff = diff(valid_header_end);
time_stamp_temp = get_data_slice(data_input, valid_header_end + 1, 6);
time_stamp_diff = diff(time_stamp_temp);
time_stamp = ts .* time_stamp_temp;

if (max(time_stamp_diff) / time_stamp_diff(2) ~= 1)
    disp("Warning: packet loss!");
end

sensor_raw_data = zeros(length(valid_header_end), 1025);
sensor_raw_data(:, 1025) = time_stamp;

for i = 1:length(valid_header_end)
    sensor_raw_data(i, (1:2:1024)) = get_data_slice(data_input, (1:4:2048) + valid_header_end(i) + 6, 2);
    sensor_raw_data(i, (2:2:1024)) = get_data_slice(data_input, (1:4:2048) + valid_header_end(i) + 8, 2);
end

%% plot 
hold on;
for i=1:10
    pause(1);
    plot(sensor_raw_data(i,1:1024));
end
hold off;


%%
