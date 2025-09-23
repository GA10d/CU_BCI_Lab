% set parameter
load('Lab2_Experiment1.mat'); 
signal_data = P_C_S.data;
[num_trails, num_samples, num_channels] = size(signal_data);
Fs = P_C_S.samplingfrequency; 

% split the data based on condition A-F, pick channel 3(FC -1)
sitting_data = signal_data(1, 2000:6000, 2);
Blinking_data = signal_data(1, 9000:13000, 2);
Rolling_data = signal_data(1, 18000:22000, 2);
Chewing_data = signal_data(1, 25000:29000, 2);
Tensing_data = signal_data(1, 33000:37000, 2);
Touching_data = signal_data(1, 44000:48000, 2);

% calculate related parameters
x = Rolling_data;  
N = length(x);    
total_t = N / Fs;
time_sequence = 0:1/Fs:total_t - 1/Fs;
fa_low = 8; fa_high = 13;
fb_low = 14; fb_high = 32;

% loop process
data_set = {sitting_data, Blinking_data, Rolling_data, Chewing_data, Tensing_data, Touching_data};
data_names = {'sitting', 'Blinking', 'Rolling', 'Chewing', 'Tensing', 'Touching'};
num_data = length(data_set);

figure('Position', [100 100 1200 1800]); 

for i = 1:num_data
    current_data = data_set{i};
    current_name = data_names{i};
    N = length(current_data);
    
    % using self-disigned bandpass
    time_sequence = 0:1/Fs:(N-1)/Fs;
    [x_filtered, f, X, X_filtered] = eegfft_bandpass(current_data, Fs, fa_low, fa_high);
    data_for_power = x_filtered(500:3500);
    power_time_domain = sum(data_for_power.^2) / length(data_for_power); 
    fprintf('time-domain average power %s: %f\n', current_name, power_time_domain);
    % 第1列：时域信号对比 (第i行)
    subplot(6, 2, 2*i - 1);
    plot(time_sequence, current_data, 'b', 'LineWidth', 1);
    hold on;
    plot(time_sequence, 100*x_filtered, 'r', 'LineWidth', 1);
    xlabel('Time (s)');
    ylabel('Amplitude(100 times)');
    title([current_name, ' - Time']);
    legend('Raw Signal', 'Processed Signal', 'Location', 'best');
    grid on;
    box on;
    
    subplot(6, 2, 2*i);
    positive_freq_idx = f >= 0;  
    f_positive = f(positive_freq_idx);
    X_positive = abs(X(positive_freq_idx))/N;  
    X_filtered_positive = abs(X_filtered(positive_freq_idx))/N;  
    
    plot(f_positive, X_positive, 'b', 'LineWidth', 1);
    hold on;
    plot(f_positive, X_filtered_positive, 'r', 'LineWidth', 1);
    xlabel('Frequency (Hz)');
    ylabel('Normalized Amplitude');
    title([current_name, ' - Spectrum（Positive）']);
    legend('Raw Spectrum', 'Processed Spectrum', 'Location', 'best');
    xlim([0 30]);  % Focus on 0-40Hz
    grid on;
    box on;
end

