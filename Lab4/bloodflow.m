% Time vector
t = linspace(0, 60, 100); % 1 minute, 100 samples
dt = t(2) - t(1); % time step

% Indicator injection rate Fi(t) in mg/s
Fi = 5 * exp(-0.1 * t);

% Simulated concentration in blood C(t) in mg/mL
C = 0.2 + 0.1 * sin(0.1 * t);

% Initialize variables
m = zeros(size(t));   % cumulative indicator amount (mg)
AUC = zeros(size(t)); % area under curve for C(t)
F = zeros(size(t));   % estimated flow over time (mL/s)

% Loop for numerical integration
for i = 2:length(t)
    m(i) = m(i-1) + Fi(i) * dt;       % cumulative m(t)
    AUC(i) = AUC(i-1) + C(i) * dt;    % integral of C(t)
    
    if AUC(i) ~= 0
        F(i) = m(i) / AUC(i);         % Fick’s principle
    else
        F(i) = NaN;                   % avoid divide-by-zero
    end
end

% Plot 1: Cumulative indicator amount m(t)
figure;
plot(t, m, 'b', 'LineWidth', 2);
title('Cumulative Indicator Amount m(t)');
xlabel('Time (s)');
ylabel('m(t) (mg)');
grid on;

% Plot 2: Concentration in blood C(t)
figure;
plot(t, C, 'r', 'LineWidth', 2);
title('Blood Concentration C(t)');
xlabel('Time (s)');
ylabel('C(t) (mg/mL)');
grid on;

% Plot 3: Estimated Flow F(t)
figure;
plot(t, F, 'g', 'LineWidth', 2);
title('Estimated Flow F(t)');
xlabel('Time (s)');
ylabel('F(t) (mL/s)');
grid on;