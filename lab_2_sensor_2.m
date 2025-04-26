clear all;
close all;
a = arduino ('COM3', 'Leonardo');
dataTemperature = zeros(1,30); %time vector
temperatureData = zeros (1,30); % tempdata
buzzerPin = 'D9';
ledPin = 'D7';
configurePin(a, buzzerPin, 'Unset');


figure
hold on
xlabel('Time(s)')
ylabel('Temperature (Celsius)');
title('Temperature Results');
grid on;

tic;
for i = 1:300
    voltage= readVoltage(a,'A1');
    temperature= (voltage -0.5)*100;
    temperature = temperature -273.15;
    dataTemperature(i)= toc;       % time vector
    temperatureData(i)= temperature;
    subplot(2,1,1)
    plot(i,temperatureData(i),'ko');
    hold on 
    drawnow;
   
     if temperature >= 120
        playTone(a, buzzerPin, 1000, 0.5); % Play 1000Hz tone for 0.5s
        writeDigitalPin(a, ledPin, 1); 
     else
         writeDigitalPin(a, ledPin, 0);
     end
end 
subplot (2,1,2)
plot(dataTemperature,temperatureData,'m-');
save('temperature_data.mat', 'dataTemperature', 'temperatureData');
load('temperature_data.mat');