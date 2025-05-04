clear all;
close all;

% Load ECG Data
data = readmatrix("ecg_dataL5.xlsx");
time = data(:,1);
ecg_signal = data(:,2);

% Define Sampling Frequency
fs = 1000;

% Plot Raw ECG Signal
figure;
plot(time, ecg_signal);
xlabel('Time (s)');
ylabel('ECG Signal (mV)');
title('Raw ECG Signal Over Time');
grid on;

% Bandpass Filter (0.5 - 150 Hz)
low_cutoff = 0.5;
high_cutoff = min(150, fs/2 - 1);  % Ensure high cutoff is below Nyquist
[b, a] = butter(4, [low_cutoff high_cutoff] / (fs / 2), 'bandpass');
filtered_ecg = filtfilt(b, a, ecg_signal);

% Notch Filter for Powerline Interference (60 Hz)
notch_freq = 60;
Wo = notch_freq / (fs / 2);  
Q = 35;
BW = Wo / Q;  % Correct bandwidth formula
[b, a] = iirnotch(Wo, BW);
notch_filtered_ecg = filtfilt(b, a, filtered_ecg);

% High-pass Filter (0.5 Hz) to Remove Baseline Wander
baseline_cutoff = 0.5;
[b, a] = butter(4, baseline_cutoff / (fs / 2), 'high');
clean_ecg = filtfilt(b, a, notch_filtered_ecg);

% Plot Filtered ECG Signals
figure;
subplot(3, 1, 1);
plot(time, ecg_signal);
title('Raw ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(3, 1, 2);
plot(time, filtered_ecg);
title('Bandpass Filtered ECG (0.5 - 150 Hz)');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(3, 1, 3);
plot(time, clean_ecg);
title('Cleaned ECG Signal (Notch + High-Pass Filter)');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

% Segment ECG Data for Different Conditions
supine_ecg = clean_ecg(time <= 20);  % First 20 seconds
seated_ecg = clean_ecg(time > 20 & time <= 40);  % 20-40 seconds
deep_breathing_ecg = clean_ecg(time > 40 & time <= 60);  % 40-60 sec
contraction_ecg = clean_ecg(time > 60);  % Remaining time for contractions

% Plot Different Conditions
figure;
subplot(4, 1, 1);
plot(time(time <= 20), supine_ecg);
title('ECG: Supine (First 20s)');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(4, 1, 2);
plot(time(time > 20 & time <= 40), seated_ecg);
title('ECG: Seated (20-40s)');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(4, 1, 3);
plot(time(time > 40 & time <= 60), deep_breathing_ecg);
title('ECG: Deep Breathing (40-60s)');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(4, 1, 4);
plot(time(time > 60), contraction_ecg);
title('ECG: Contractions Every 20s (Post 60s)');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

disp('ECG Signal Processing Complete.');
