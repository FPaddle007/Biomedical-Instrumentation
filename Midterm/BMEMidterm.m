clear all;
close all;

%% PART A: EMG SIGNAL PROCESSING

% Load EMG Data
emg_data = readmatrix("emg_dataL1.xlsx");
time_emg = emg_data(:,1);
emg_signal = emg_data(:,2);

% Define Sampling Frequency
fs_emg = 1000; 

% Plot Raw EMG Signal
figure;
plot(time_emg, emg_signal);
xlabel('Time (s)');
ylabel('EMG Signal (mV)');
title('Raw EMG Signal Over Time');
grid on;

% Bandpass Filter (0.5 - 450 Hz)
[b_emg, a_emg] = butter(4, [0.5 450] / (fs_emg / 2), 'bandpass');
filtered_emg = filtfilt(b_emg, a_emg, emg_signal);

% Notch Filter for Powerline Interference (60 Hz)
[b_notch, a_notch] = iirnotch(60 / (fs_emg / 2), 60 / (fs_emg / 2) / 35);
notch_filtered_emg = filtfilt(b_notch, a_notch, filtered_emg);

% High-pass Filter (0.5 Hz) to Remove Baseline Wander
[b_hp, a_hp] = butter(4, 0.5 / (fs_emg / 2), 'high');
clean_emg = filtfilt(b_hp, a_hp, notch_filtered_emg);

% Plot Filtered EMG Signals
figure;
subplot(3, 1, 1);
plot(time_emg, emg_signal);
title('Raw EMG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(3, 1, 2);
plot(time_emg, filtered_emg);
title('Bandpass Filtered EMG');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(3, 1, 3);
plot(time_emg, clean_emg);
title('Cleaned EMG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

disp('EMG Signal Processing Complete.');

%% PART A: ECG SIGNAL PROCESSING

% Load ECG Data
ecg_data = readmatrix("ecg_dataL5.xlsx");
time_ecg = ecg_data(:,1);
ecg_signal = ecg_data(:,2);

% Define Sampling Frequency
fs_ecg = 1000;

% Plot Raw ECG Signal
figure;
plot(time_ecg, ecg_signal);
xlabel('Time (s)');
ylabel('ECG Signal (mV)');
title('Raw ECG Signal Over Time');
grid on;

% Bandpass Filter (0.5 - 150 Hz)
[b_ecg, a_ecg] = butter(4, [0.5 150] / (fs_ecg / 2), 'bandpass');
filtered_ecg = filtfilt(b_ecg, a_ecg, ecg_signal);

% Notch Filter (60 Hz)
notch_filtered_ecg = filtfilt(b_notch, a_notch, filtered_ecg);

% High-pass Filter (0.5 Hz)
clean_ecg = filtfilt(b_hp, a_hp, notch_filtered_ecg);

% Plot Filtered ECG Signals
figure;
subplot(3, 1, 1);
plot(time_ecg, ecg_signal);
title('Raw ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(3, 1, 2);
plot(time_ecg, filtered_ecg);
title('Bandpass Filtered ECG');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(3, 1, 3);
plot(time_ecg, clean_ecg);
title('Cleaned ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

disp('ECG Signal Processing Complete.');

%% PART B: NORMALIZATION

normalized_ecg = (clean_ecg - min(clean_ecg)) / (max(clean_ecg) - min(clean_ecg));
normalized_emg = (clean_emg - min(clean_emg)) / (max(clean_emg) - min(clean_emg));

figure;
subplot(2,1,1);
plot(time_ecg, normalized_ecg);
title('Normalized ECG Signal');
xlabel('Time (s)');
ylabel('Normalized Amplitude');

subplot(2,1,2);
plot(time_emg, normalized_emg);
title('Normalized EMG Signal');
xlabel('Time (s)');
ylabel('Normalized Amplitude');

disp('Normalization complete.');

%% PART B: EMG MEASUREMENTS (RMS & MAV)

clench_intervals = [70 80; 90 100; 110 120];
rms_values = zeros(1,3);
mav_values = zeros(1,3);

for i = 1:3
    clench_data = clean_emg(time_emg >= clench_intervals(i,1) & time_emg <= clench_intervals(i,2));
    rms_values(i) = rms(clench_data);
    mav_values(i) = mean(abs(clench_data));
    
    fprintf('Clench %d - RMS: %.4f, MAV: %.4f\n', i, rms_values(i), mav_values(i));
end

disp(table((1:3)', rms_values', mav_values', 'VariableNames', {'Clench #', 'RMS', 'MAV'}));

%% PART B: R-PEAK DETECTION & CARDIAC CYCLE ANALYSIS

[r_peaks, r_locs] = findpeaks(clean_ecg, 'MinPeakHeight', mean(clean_ecg) + 0.5*std(clean_ecg), 'MinPeakDistance', fs_ecg*0.6);
r_times = time_ecg(r_locs);

figure;
plot(time_ecg, clean_ecg);
hold on;
plot(r_times, r_peaks, 'ro');
title('R-peaks in ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
grid on;
hold off;

% Compute R-R Intervals
rr_intervals = diff(r_times);

% Estimate P-R and Q-T Intervals
pr_intervals = rr_intervals * 0.2; 
qt_intervals = rr_intervals * 0.4;

mean_rr = mean(rr_intervals);
mean_pr = mean(pr_intervals);
mean_qt = mean(qt_intervals);

fprintf('Mean R-R Interval: %.4f s\n', mean_rr);
fprintf('Mean P-R Interval: %.4f s\n', mean_pr);
fprintf('Mean Q-T Interval: %.4f s\n', mean_qt);

%% PART B: CONDITION-BASED ECG ANALYSIS

% Extract R-R intervals for each condition
rr_supine = rr_intervals(r_times(1:end-1) <= 20);
rr_seated = rr_intervals(r_times(1:end-1) > 20 & r_times(1:end-1) <= 40);
rr_inhale = rr_intervals(r_times(1:end-1) > 40 & r_times(1:end-1) <= 50);
rr_exhale = rr_intervals(r_times(1:end-1) > 50 & r_times(1:end-1) <= 60);
rr_contraction = rr_intervals(r_times(1:end-1) > 60);

% Function to extract up to 3 cardiac cycles per condition
get_cycles = @(rr) [rr(1:min(length(rr),3)); NaN(3 - min(length(rr),3),1)];

% Extract first three cardiac cycles per condition
cycles_supine = get_cycles(rr_supine);
cycles_seated = get_cycles(rr_seated);
cycles_inhale = get_cycles(rr_inhale);
cycles_exhale = get_cycles(rr_exhale);
cycles_contraction = get_cycles(rr_contraction);

% Compute mean for each condition
mean_supine = mean(rr_supine, 'omitnan');
mean_seated = mean(rr_seated, 'omitnan');
mean_inhale = mean(rr_inhale, 'omitnan');
mean_exhale = mean(rr_exhale, 'omitnan');
mean_contraction = mean(rr_contraction, 'omitnan');

% Combine all cycle data into a single matrix
all_cycles = [cycles_supine, cycles_seated, cycles_inhale, cycles_exhale, cycles_contraction]';

% Create table with consistent row size
conditions = {'Supine'; 'Seated'; 'Start of Inhale'; 'Start of Exhale'; 'During Muscle Contractions'};
means = [mean_supine; mean_seated; mean_inhale; mean_exhale; mean_contraction];

% Display table
table_2_1 = table(conditions, all_cycles(:,1), all_cycles(:,2), all_cycles(:,3), means, ...
           'VariableNames', {'Condition', 'Cycle 1', 'Cycle 2', 'Cycle 3', 'Mean'});

disp(table_2_1);

%% SAVE VARIABLES TO .MAT FILE

save('processed_data.mat', 'clean_emg', 'clean_ecg', 'normalized_ecg', 'normalized_emg', ...
    'r_peaks', 'r_times', 'rr_intervals', 'pr_intervals', 'qt_intervals', ...
    'rms_values', 'mav_values', 'mean_rr', 'mean_pr', 'mean_qt', ...
    'cycles_supine', 'cycles_seated', 'cycles_inhale', 'cycles_exhale', 'cycles_contraction', ...
    'mean_supine', 'mean_seated', 'mean_inhale', 'mean_exhale', 'mean_contraction');

disp('Processed data saved to processed_data.mat.');
