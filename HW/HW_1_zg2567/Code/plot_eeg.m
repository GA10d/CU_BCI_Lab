eeg_data = P_C_S.data;          
fs = P_C_S.samplingfrequency;   
num_channels = size(eeg_data, 3); 
% recreate time based on the sample and fs
time = (0 : size(eeg_data, 2)-1) / fs;

figure('Name', 'Raw EEG Signals', 'Position', [100 100 1000 600]);

for i = 1 : num_channels
    % create image for each channel
    subplot(num_channels, 1, i);
    
    plot(time, squeeze(eeg_data(1, :, i)));
    title(['Channel ' num2str(P_C_S.channels(i))], 'FontSize', 12);
    xlabel('Time (s)', 'FontSize', 10);
    ylabel('Amplitude', 'FontSize', 10);
    
    grid on;
    box on;
    xlim([time(1) time(end)]);
end

figure('Name', 'Raw EEG Signals sample point based', 'Position', [100 100 1000 600]);

for i = 1 : num_channels
    % create image for each channel
    subplot(num_channels, 1, i);
    sample_size = (0:size(eeg_data, 2)-1);
    plot(sample_size, squeeze(eeg_data(1, :, i)));
    title(['Channel ' num2str(P_C_S.channels(i))], 'FontSize', 12);
    xlabel('Time (s)', 'FontSize', 10);
    ylabel('Amplitude', 'FontSize', 10);
    
    grid on;
    box on;
    xlim([time(1) time(end)]);
end