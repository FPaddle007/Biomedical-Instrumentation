load temperature_data.mat
% Calculate rate of temperature change (dT/dt)
dT = diff(temperatureData);  % Temperature differences
dt = diff(dataTemperature);  % Time differences
rate_of_change = dT ./ dt;  % Rate of temperature change (dT/dt)


% Plot rate of temperature change
figure
plot(dataTemperature(2:end), rate_of_change, 'b-o');
xlabel('Time (s)')
ylabel('Rate of Temperature Change (Celsius/s)')
title('Rate of Temperature Change')
grid on

% Estimate time to reach 120°C (threshold)
time_threshold = 120;  % Threshold temperature
T0 = temperatureData(1);  % Initial temperature
avg_rate = mean(rate_of_change);  % Average rate of temperature change

% Estimate time to reach the threshold temperature
estimated_time = (time_threshold - T0) / avg_rate;
fprintf('Estimated time to reach 120°C = %f seconds', estimated_time);

% Compare with experimental values
[~, idx_threshold] = min(abs(temperatureData - time_threshold));  % Find the index where temperature is closest to 120°C
experimental_time = dataTemperature(idx_threshold);  % Time when temperature first exceeds 120°C
fprintf('Experimental time to reach 120°C = %f seconds', experimental_time);