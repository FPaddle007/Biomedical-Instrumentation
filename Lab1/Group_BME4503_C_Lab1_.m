% LED Dimming and Photoresistor Data Acquisition
% This script dims an LED using a potentiometer and logs data from a photoresistor.
% The photoresistor's voltage is plotted against the LED's brightness levels.

% Hardware setup assumptions:
% - Potentiometer adjusts LED brightness.
% - Photoresistor placed in front of the LED and connected to an analog pin.
%% Parameters

ledPin = 'D9';          % PWM pin for LED
photoResPin = 'A0';     % Analog pin for photoresistor
numSamples = 50;        % Data points to collect
brightness = linspace(1, 0, numSamples);  % Brightness levels (high to low)
voltages = zeros(1, numSamples);          % Store photoresistor readings

% Initialize Arduino
board = arduino();
%% Data Collection

for idx = 1:numSamples
    % Set LED brightness using PWM
    writePWMDutyCycle(board, ledPin, brightness(idx));

    % Measure photoresistor voltage
    voltages(idx) = readVoltage(board, photoResPin);

    % Short delay for readings to stabilize
    pause(0.1);
end

% Turn off the LED connected to pin D9 to conserve battery power and avoid damage to the hardware
writePWMDutyCycle(board, ledPin, 0);
%% Plotting Results

figure;
plot(brightness, voltages, 'o-', 'LineWidth', 1.5);
xlabel('LED Brightness');
ylabel('Photoresistor Voltage (V)');
title('Light Intensity vs. Brightness');
grid on;
%% Notes
% This script dims the LED step-by-step, recording light intensity changes with 
% a photoresistor. The plot reveals how the light level varies as the brightness 
% decreases. Ensure your components are connected properly.
save('led_photoresistor_data.mat', 'brightness', 'voltages');
load('led_photoresistor_data.mat');