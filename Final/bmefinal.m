% PPG Signal Acquisition and Analysis using Arduino

% ========== Setup ==========
close all;
clear all;

% Connect to Arduino
a = arduino('COM3', 'Leonardo'); 
analogPin = 'A1';  % Change if you use another analog input pin

% Testing purposes (turn on LED)
writeDigitalPin(a,"D12", 1);

% Sampling parameters
fs = 200;            % Sampling frequency (Hz)
duration = 30;       % Duration of data collection (seconds)
samples = fs * duration;
data = zeros(1, samples);
time = (0:samples-1) / fs;

disp('Starting data acquisition...');

% ========== Setup Plot ==========
figure;
hPlot = plot(nan, nan, 'b');
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Raw PPG Signal (Transmissive Sensor)');
grid on;
xlim([0, duration]);

% ========== Data Acquisition ==========
tic  % Start timer

for i = 1:samples
    data(i) = readVoltage(a, analogPin);
    time(i) = toc;

    % Update plot quickly
    set(hPlot, 'XData', time(1:i), 'YData', data(1:i));
    drawnow;  % Use normal drawnow for faster updates
end

% Save raw data
%save('ppg_raw_data.mat', 'time', 'data');
%%
% ========== Preprocessing ==========
% Normalize signal
data_norm = (data - mean(data)) / std(data);

% Apply low-pass filter to remove high-frequency noise
fc = 4;  % cutoff frequency in Hz
[b, a_filt] = butter(4, fc / (fs / 2), 'low'); 
filtered_data = filtfilt(b, a_filt, data_norm);

% ========== Peak Detection ==========
%[~, locs] = findpeaks(filtered_data, 'MinPeakHeight', 0, 'MinPeakDistance', round(0.5 * fs));
[~, locs] = findpeaks(data, 'MinPeakHeight', 0, 'MinPeakDistance', round(0.5 * fs));
% Calculate heart rate
peak_intervals = diff(locs) ./ diff(time(locs));  % More accurate using time
avg_peak_interval = mean(peak_intervals);
heart_rate = (avg_peak_interval / duration) * 60
%%
% ========== Filtered Signal Plot ==========
figure;
plot(time, filtered_data, 'b');
hold on;
plot(time(locs), filtered_data(locs), 'ro');
xlabel('Time (s)');
ylabel('Normalized Voltage');
title(sprintf('Filtered PPG Signal with Peaks — Heart Rate: %.2f BPM', heart_rate));
grid on;
xlim([0, 30]);

% ========== Display Results ==========
fprintf('Heart Rate: %.2f BPM\n', heart_rate);
