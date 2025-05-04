% Create Arduino project
% Define Morse code timing(in seconds)
unitTime= 0.5; % Base unit time for morse code (e.g., 500ms)
dashTime= 3 * unitTime; %Dash is 3 units long
ledPin= 'D13'; % Define the digital pin connected to the LED
% Blink the letter 'T' in Morse code
disp('Blinking letter T in Morse code...');
writeDigitalPin(arduino, ledPin,1); % Turn LED ON
pause(dashTime); %keep it on for dash duration
writeDigitalPin(arduino, ledPin,0); % Turn LED OFF
pause(unitTime); % pause after the dash
disp('Done');
save('morse_code_data.mat', 'unitTime', 'dashTime', 'ledPin');
load('morse_code_data.mat');