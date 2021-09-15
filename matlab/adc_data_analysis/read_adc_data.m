clear;
close all;
clc;
%% load log data
if isfile('./iladata.csv')
    iladata = import_adc_file('./iladata.csv', 3);
    adc_data = table2array(iladata(:,4));
    plot(abs(fft(adc_data)));
else
    disp("No ila data");
end