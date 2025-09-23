load('Lab2_Experiment 2_2.mat');
eeg_data = P_C_S.data;  
[num_trails, num_samples, num_channels] = size(eeg_data);


eeg_data_dc_removed = eeg_data;

for i = 1:num_trails
    for j = 1:num_channels
        single_data = squeeze(eeg_data(i, :, j));  
        dc_component = mean(single_data);   
        eeg_data_dc_removed(i, :, j) = single_data - dc_component; 
    end
end

% save processed data
P_C_S_dc_removed = P_C_S;
P_C_S_dc_removed.data = eeg_data_dc_removed;
P_C_S_dc_removed.comment = [P_C_S.comment '; DC eliminated'];


fs = P_C_S.samplingfrequency;  
time = (0:num_samples-1) / fs; 
unit = P_C_S.unit;             
disp(P_C_S.data(3));
figure('Name', 'DC(blue) vs No DC(Red)', 'Position', [100 100 1200 200*(num_channels)]);

for j = 1:num_channels 
    subplot(num_channels, 1, j);
    
    % plot original signals
    plot(time, squeeze(eeg_data(1, :, j)), 'b', 'LineWidth', 0.6);
    hold on;
    
    % plot processed signals
    plot(time, squeeze(eeg_data_dc_removed(1, :, j)), 'r', 'LineWidth', 0.8);
    
    % set labels
    title(['Channel ' num2str(P_C_S_dc_removed.channels(j))], 'FontSize', 12);
    xlabel('Time (s)', 'FontName', 'Arial', 'FontSize', 10);
    ylabel(['Amplitude '], 'FontName', 'Arial', 'FontSize', 10);
    
    % 添加图例和网格
    legend({'Raw', 'Processed'}, 'FontName', 'Arial', 'FontSize', 8, 'Location', 'best');
    grid on;
    box on;
    xlim([time(1) time(end)]);  
    hold off;
end



% 添加总标题
sgtitle('DC(blue) vs No DC(Red) for data in experiment 2-2', 'FontName', 'Arial', 'FontSize', 14);