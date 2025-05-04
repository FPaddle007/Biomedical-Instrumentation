clear all;
close all;

% Load Data
data = readmatrix("emg_dataL1.xlsx");
time = data(:,1);
emg_signal = data(:,2);

% Define Sampling Frequency
fs = 1000; 

% Plot Raw EMG Signal
figure;
plot(time, emg_signal);
xlabel('Time (s)');
ylabel('EMG Signal (mV)');
title('Raw EMG Signal Over Time');
grid on;

% Bandpass Filter (0.5 - 450 Hz for EMG)
low_cutoff = 0.5;  
high_cutoff = min(450, fs/2 - 1);  % Ensure high_cutoff is below Nyquist
[b, a] = butter(4, [low_cutoff high_cutoff] / (fs / 2), 'bandpass');
filtered_signal = filtfilt(b, a, emg_signal);

% Notch Filter for Powerline Interference (60 Hz)
notch_freq = 60;
Wo = notch_freq / (fs / 2);  % Normalized frequency
Q = 35;  
BW = Wo / Q;  % Correct formula for notch filter
[b, a] = iirnotch(Wo, BW);
notch_filtered_signal = filtfilt(b, a, filtered_signal);

% High-pass Filter (0.5 Hz) to Remove Baseline Wander
baseline_cutoff = 0.5;
[b, a] = butter(4, baseline_cutoff / (fs / 2), 'high');
clean_signal = filtfilt(b, a, notch_filtered_signal);

% Plot Filtered Signals
figure;
subplot(3, 1, 1);
plot(time, emg_signal);
title('Raw EMG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(3, 1, 2);
plot(time, filtered_signal);
title('Bandpass Filtered (0.5 - 450 Hz)');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(3, 1, 3);
plot(time, clean_signal);
title('Cleaned EMG Signal (Notch + High-Pass Filter)');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

% Display Completion
disp('EMG Signal Processing Complete.');
