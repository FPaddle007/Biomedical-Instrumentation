clear all;
close all;

% Arduino type and port
a = arduino ('COM3', 'Leonardo');

% Defining pins
pinSensor = 'A0'; % Myoware sensor
ledPin1 = 'D9'; % LED 1
ledPin2 = 'D10'; % LED 2
ledPin3 = 'D11'; % LED 3

% LED outputs
configurePin(a, ledPin1, 'DigitalOutput');
configurePin(a, ledPin2, 'DigitalOutput');
configurePin(a, ledPin3, 'DigitalOutput');

% Muscle Thresholds
Threshold1 = 860; % Resting
Threshold2 = 870; % Weak
Threshold3 = 880; % Strong

% Store time and EMG data
time = zeros(1,30);
emg = zeros(1,30);

% Data collection duration
length = 30;
startingTime = tic;

% Plot figures
figure;
h = plot(NaN, NaN);
title("EMG Signal in Real Time");
xlabel ("Time (in secs");
ylabel("Muscle Signal (0-123)");
grid on;

% Loop to collect data for 30 secs
while toc(startingTime) < length
    % Read muscle sensor values
    muscleReadings = readVoltage(a, pinSensor) * (1023/5); % Equation to convert voltage to signal
    % Data to plot
    newTime = toc(startingTime);
    time = [time; newTime];
    emg = [emg; muscleReadings];

    % Update plot
    set(h, 'XData', time, 'YData', emg);
    drawnow;
    fprintf("Muscle Signal: %f\n", muscleReadings); % in case we have to troubleshoot

    % LED control based on muscle signal
    if muscleReadings < Threshold1
        writeDigitalPin(a, ledPin1, 1);
        writeDigitalPin(a, ledPin2, 0);
        writeDigitalPin(a, ledPin3, 0);

    else if muscleReadings < Threshold2
        writeDigitalPin(a, ledPin1, 0);
        writeDigitalPin(a, ledPin2, 1);
        writeDigitalPin(a, ledPin3, 0);

    else if muscleReadings < Threshold3
        writeDigitalPin(a, ledPin1, 0);
        writeDigitalPin(a, ledPin2, 0);
        writeDigitalPin(a, ledPin3, 1);

    else
        writeDigitalPin(a, ledPin1, 0);
        writeDigitalPin(a, ledPin2, 0);
        writeDigitalPin(a, ledPin3, 0);
    end
end

% Final plots of the EMG data
figure;
plot(time, emg);
title("EMG Signal Over Time");
xlabel ("Time (in secs");
ylabel("Muscle Signal (0-123)");
grid on;

% Save all data
data1 = time;
data2 = emg;
save('data1', 'data2');
