%% Load data
data = load('task2_raw.mat');
time = data.y(1,:);
signal = data.y(2,:);
fs = 256;

%% Extract segments
idx_20Hz = (time >= 10 & time <= 50);
idx_30Hz = (time >= 70 & time <= 110);

sig20 = signal(idx_20Hz);
sig30 = signal(idx_30Hz);

%% Function to compute *correct* FFT half spectrum
function [f, mag] = myFFT(x, fs)
    N = length(x);
    X = fft(x);
    X = X(1:floor(N/2));          % keep first half
    mag = abs(X);                 % magnitude
    f = (0:floor(N/2)-1) * fs/N;  % frequency axis
end

%% Compute FFT for both
[f20, mag20] = myFFT(sig20, fs);
[f30, mag30] = myFFT(sig30, fs);

%% Plot both on one figure
figure;
plot(f20, mag20, 'b', 'LineWidth', 1.5); hold on;
plot(f30, mag30, 'r', 'LineWidth', 1.5);

xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('FFT for 20 Hz and 30 Hz Segments');
legend('20 Hz Segment', '30 Hz Segment');
xlim([0 60]);
grid on;
