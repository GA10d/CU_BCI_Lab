clear;clc;
fs = 256;

[exp1_data,exp2_data,exp1_flag,exp2_flag] = load_data();

ts = exp1_flag.ans;t = ts.Time;x = ts.Data;   
exp1_flag_array = [ts.Time.'; ts.Data.'];
ts = exp2_flag.ans;t = ts.Time;x = ts.Data;   
exp2_flag_array = [ts.Time.'; ts.Data.'];

[exp1_time_start, exp1_time_end] = get_index(exp1_flag_array);
[exp2_time_start, exp2_time_end] = get_index(exp2_flag_array);
disp(exp1_time_end)
exp1_eeg = align_data(exp1_data.y,30, 300);
exp2_eeg = align_data(exp2_data.y,30, 300);

plot_data(exp1_eeg,exp2_eeg,fs);
plot_diff(exp1_eeg,exp2_eeg)

env40 = exp1_eeg(:).';
env35 = exp2_eeg(:).';

t = (0:length(env40)-1)/fs;

keep = (t >= 100 & t <= 300);
env40 = env40(keep);
env35 = env35(keep);

A40 = mean(env40);         
A35 = mean(env35);

P40 = mean(env40.^2);      
P35 = mean(env35.^2);

fprintf("Mean amplitude 35Hz = %.6f\n", A35);
fprintf("Mean amplitude 40Hz = %.6f\n", A40);
fprintf("Mean power 35Hz     = %.6f\n", P35);
fprintf("Mean power 40Hz     = %.6f\n", P40);
fprintf("Amplitude diff (35-40) = %.6f\n", A35-A40);
fprintf("Power diff (35-40)     = %.6f\n", P35-P40);


figure('Color','w');
subplot(1,2,1);
bar([A35 A40],'FaceColor',[0.6 0.8 1]); title('Mean Envelope (Amplitude)');
set(gca,'XTickLabel',{'35 Hz','40 Hz'}); ylabel('Amplitude'); grid on;

subplot(1,2,2);
bar([P35 P40],'FaceColor',[1 0.7 0.7]); title('Mean Envelope^2 (Power)');
set(gca,'XTickLabel',{'35 Hz','40 Hz'}); ylabel('Power'); grid on;






function [exp1_data,exp2_data,exp1_flag,exp2_flag] = load_data()
    exp1_data = load("F:\Documents\GitHub\CU_BCI_Lab\Lab\Lab 8\Data\Lab_7_exp2_40.mat");
    exp2_data = load("F:\Documents\GitHub\CU_BCI_Lab\Lab\Lab 8\Data\Lab_7_exp2_35.mat");
    exp1_flag = load("F:\Documents\GitHub\CU_BCI_Lab\Lab\Lab 8\Data\Lab7_sound_trigger_40.mat");
    exp2_flag = load("F:\Documents\GitHub\CU_BCI_Lab\Lab\Lab 8\Data\Lab7_sound_trigger_35.mat");
end 

function [time_start, time_end] = get_index(data)
    time_start = 0;
    time_end   = 0;
    for i = 2:size(data,2)
        if data(2,i-1) == 0 && data(2,i) == 1
            time_start = data(1,i);
        end
        if data(2,i-1) == 1 && data(2,i) == 0
            time_end = data(1,i);
            break
        end
    end
end

function aligned_data = align_data(signal,time_start, time_end)
    time = signal(1,:);
    idx = (time > time_start) & (time < time_end);

    aligned_data = signal(2:end, idx); 
end

function plot_data(exp1_eeg,exp2_eeg,fs)
    N = length(exp1_eeg);
    t = (0:N-1) / fs;   
    
    figure('Color','w'); 
    
    plot(t, exp1_eeg, 'LineWidth', 1.8, 'Color', [0.2 0.4 0.9]); hold on;
    plot(t, exp2_eeg, 'LineWidth', 1.8, 'Color', [0.9 0.3 0.2]);
    
    xlabel('Time (s)', 'FontSize', 12);
    ylabel('Amplitude (\muV)', 'FontSize', 12);
    title('EEG Signal Comparison (1×N)', 'FontSize', 14);
    
    legend('Exp1 (38–42 Hz)', 'Exp2 (33–37 Hz)', 'Location', 'best');
    
    grid on;
end

function plot_diff(exp1_eeg,exp2_eeg)
    fs = 256;  
    
    e40 = exp1_eeg(:).';   
    e35 = exp2_eeg(:).';   

    t = (0:length(e40)-1) / fs;
    
    diff_eeg = e40 - e35;

    
    figure('Color','w');
    plot(t, diff_eeg, 'LineWidth', 1.8, 'Color', [0.2 0.2 0.9]); hold on;
    
    yline(0, '--', 'LineWidth', 1.2, 'Color', [0.4 0.4 0.4]);
    
    xlabel('Time (s)', 'FontSize', 12);
    ylabel('\Delta Envelope (40Hz - 35Hz)', 'FontSize', 12);
    title('Difference Between Conditions', 'FontSize', 14);
    grid on;
    
    legend('40 Hz - 35 Hz', 'Baseline = 0', 'Location', 'best');

end