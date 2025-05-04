clear all;
close all;
%
% % Arduino type and port
a = arduino ('COM3', 'Leonardo');

% Defining pins
pinSensor = 'A0'; % Myoware sensor
ledPin1 = 'D9'; % LED 1
ledPin2 = 'D10'; % LED 2
ledPin3 = 'D11'; % LED 3
%
% % LED outputs
% configurePin(a, ledPin1, 'DigitalOutput');
% configurePin(a, ledPin2, 'DigitalOutput');
% configurePin(a, ledPin3, 'DigitalOutput');

% Muscle Thresholds
Threshold1 = 0.5; % Resting
Threshold2 = 1; % Weak
Threshold3 = 4.5; % Strong

% Store time and EMG data
time = 30;
emg = zeros(1,30);

%%
% Data collection duration
length = 30;
startingTime = tic;

% Plot figures
figure(1);
clf
% h = plot(NaN, NaN);
h = animatedline();
% title("EMG Signal in Real Time");
% xlabel ("Time (in secs");
% ylabel("Muscle Signal (0-123)");
% grid on;

% Loop to collect data for 400 secs
tic
while toc < time
%for i=1:500
   
    % Read muscle sensor values
    muscleReadings = readVoltage(a, 'A0'); % Read voltage values
    % Data to plot
    %newTime = toc(startingTime);
    %     time = [time; newTime];
    %     emg = [emg; muscleReadings];

    % Update plot
    %     set(h, 'XData', time, 'YData', emg);
    %     drawnow;
    %     fprintf("Muscle Signal: %f\n", muscleReadings); % in case we have to troubleshoot

    % LED control based on muscle signal
      if muscleReadings < Threshold1
            writeDigitalPin(a, ledPin1, 1);
            writeDigitalPin(a, ledPin2, 0);
            writeDigitalPin(a, ledPin3, 0); 
      else if muscleReadings > Threshold1 && muscleReadings < Threshold2
            writeDigitalPin(a, ledPin1, 0);
            writeDigitalPin(a, ledPin2, 1);
            writeDigitalPin(a, ledPin3, 0);
        else 
            writeDigitalPin(a, ledPin1, 0);
            writeDigitalPin(a, ledPin2, 0);
            writeDigitalPin(a, ledPin3, 1);   
      end
      end
        toc
    % Final plots of the EMG data
    figure(1);
    addpoints(h, toc, muscleReadings);
    hold on
    title("EMG Signal Over Time");
    xlabel ("Time (in secs");
    ylabel("Muscle Signal (0-123)");
    grid on;
end
% Save all data
% data1 = time;
% data2 = emg;
% % save('data1', 'data2');
