clc;clear;
fs = 256;
[data1, data2, data3, data4, flag1, flag2, flag3, flag4] = load_data();

[st1, et1] = get_index(flag1.y); [st2, et2] = get_index(flag2.y);
[st3, et3] = get_index(flag3.y); [st4, et4] = get_index(flag4.y);

eeg1 = align_data(data1.y, st1, et1); eeg2 = align_data(data2.y, st2, et2);
eeg3 = align_data(data3.y, st3, et3); eeg4 = align_data(data4.y, st4, et4);

[f1, mag1] = compute_avg_fft(eeg1, fs);
[f2, mag2] = compute_avg_fft(eeg2, fs);
[f3, mag3] = compute_avg_fft(eeg3, fs);
[f4, mag4] = compute_avg_fft(eeg4, fs);

plot_fft(f1, mag1, f2, mag2, f3, mag3, f4, mag4)


fs = 256;  % sampling rate

m = zeros(4,2);  % rows = conditions, cols = [40Hz, 35Hz]

m(1,1) = avgAt(eeg1, 40, fs);  m(1,2) = avgAt(eeg1, 35, fs); % Attend LEFT
m(2,1) = avgAt(eeg2, 40, fs);  m(2,2) = avgAt(eeg2, 35, fs); % Attend RIGHT
m(3,1) = avgAt(eeg3, 40, fs);  m(3,2) = avgAt(eeg3, 35, fs); % Attend BOTH
m(4,1) = avgAt(eeg4, 40, fs);  m(4,2) = avgAt(eeg4, 35, fs); % UNATTENDED

conds = {'Attend LEFT'; 'Attend RIGHT'; 'Attend BOTH'; 'UNATTENDED'};
T = table(conds, m(:,1), m(:,2), 'VariableNames', {'Condition', 'Mag40Hz', 'Mag35Hz'});
disp(T);

figure;
bar(m,'grouped');
set(gca, 'XTickLabel', conds, 'XTickLabelRotation', 15);
ylabel('Average Magnitude');
legend('40 Hz (Left ear modulator)','35 Hz (Right ear modulator)', 'Location','northwest');
title('ASSR Average Magnitude at Modulator Frequencies');
grid on;



function val = avgAt(eeg, freq, fs)
    % eeg: channels x samples
    % freq: target frequency (e.g. 35 or 40)
    % fs: sampling rate

    L = size(eeg, 2);
    fft_vals = fft(eeg, [], 2);   % FFT across time for each channel
    k = round(freq / fs * L) + 1; % index of frequency bin
    mag = abs(fft_vals(:, k));    % magnitude at that frequency for all channels
    val = mean(mag);              % average across channels
end

function [data1, data2, data3, data4, flag1, flag2, flag3, flag4] = load_data()
    data1 = load('F:\Documents\GitHub\CU_BCI_Lab\HW\HW_6_zg2567\Data\Task 1\eeg_1.mat');
    data2 = load('F:\Documents\GitHub\CU_BCI_Lab\HW\HW_6_zg2567\Data\Task 1\eeg_2.mat');
    data3 = load('F:\Documents\GitHub\CU_BCI_Lab\HW\HW_6_zg2567\Data\Task 1\eeg_3.mat');
    data4 = load('F:\Documents\GitHub\CU_BCI_Lab\HW\HW_6_zg2567\Data\Task 1\eeg_4.mat');
    flag1 = load('F:\Documents\GitHub\CU_BCI_Lab\HW\HW_6_zg2567\Data\Task 1\time_trigger_1.mat');
    flag2 = load('F:\Documents\GitHub\CU_BCI_Lab\HW\HW_6_zg2567\Data\Task 1\time_trigger_2.mat');
    flag3 = load('F:\Documents\GitHub\CU_BCI_Lab\HW\HW_6_zg2567\Data\Task 1\time_trigger_3.mat');
    flag4 = load('F:\Documents\GitHub\CU_BCI_Lab\HW\HW_6_zg2567\Data\Task 1\time_trigger_4.mat');
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

function [f, avg_mag] = compute_avg_fft(eeg, fs)
    [~, numSamp] = size(eeg);
    fft_vals = fft(eeg, [], 2);         
    fft_vals = fft_vals(:,1:floor(numSamp/2)); 
    mag = abs(fft_vals);
    avg_mag = mean(mag, 1);
    f = (0:floor(numSamp/2)-1) * (fs/numSamp);
end

function plot_fft(f1, mag1, f2, mag2, f3, mag3, f4, mag4)


figure;

subplot(4,1,1);
plot(f1, mag1, 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('i. Attend to LEFT (count wiggles in left ear)');

subplot(4,1,2);
plot(f2, mag2, 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('ii. Attend to RIGHT (count wiggles in right ear)');

subplot(4,1,3);
plot(f3, mag3, 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('iii. Attend to BOTH (count wiggles in both ears)');

subplot(4,1,4);
plot(f4, mag4, 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('iv. UNATTENDED (secondary task: watch silent movie)');

sgtitle('Average FFT Magnitude Across Channels');
end