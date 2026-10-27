clc; clear; close all;
fs = 256;   

% load data
task1_12 = load("Task1_12Hz.mat"); 
data_12 = task1_12.y; 
idx_12 = data_12(1,:) > 10;

task1_20 = load("Task1_20Hz.mat"); 
data_20 = task1_20.y; 
idx_20 = data_20(1,:) > 10;

task1_30 = load("Task1_30Hz.mat"); 
data_30 = task1_30.y; 
idx_30 = data_30(1,:) > 10;

% compute FFT for each channel
[f1, mag1_ch] = compute_fft_each_channel(data_12(2:9, idx_12), fs);
[f2, mag2_ch] = compute_fft_each_channel(data_20(2:9, idx_20), fs);
[f3, mag3_ch] = compute_fft_each_channel(data_30(2:9, idx_30), fs);

avg_mag1 = mean(mag1_ch, 1);
avg_mag2 = mean(mag2_ch, 1);
avg_mag3 = mean(mag3_ch, 1);

figure;
plot(f1, avg_mag1, 'b', 'LineWidth', 1.5); hold on;
plot(f2, avg_mag2, 'r', 'LineWidth', 1.5);
plot(f3, avg_mag3, 'g', 'LineWidth', 1.5);

xlim([0 60]); 
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Average FFT for 12 Hz, 20 Hz, and 30 Hz Tasks');
legend('12 Hz Task', '20 Hz Task', '30 Hz Task');
grid on;


amp12 = extract_freq_amp(f1, mag1_ch, 12);
amp20 = extract_freq_amp(f2, mag2_ch, 20);
amp30 = extract_freq_amp(f3, mag3_ch, 30);

channelLabels = {'Fz','Cz','P3','P4','Pz','PO7','PO8','Oz'};

figure;
subplot(1,3,1);
bar(amp12);
set(gca,'XTick',1:8,'XTickLabel',channelLabels);
xtickangle(45);
title('Amplitude at 12 Hz');
ylabel('Magnitude');

subplot(1,3,2);
bar(amp20);
set(gca,'XTick',1:8,'XTickLabel',channelLabels);
xtickangle(45);
title('Amplitude at 20 Hz');

subplot(1,3,3);
bar(amp30);
set(gca,'XTick',1:8,'XTickLabel',channelLabels);
xtickangle(45);
title('Amplitude at 30 Hz');


% load electrode location file
locFile = 'BCI.locs';
figure;
plot(f1, avg_mag1, 'b', 'LineWidth', 1.5); hold on;
plot(f2, avg_mag2, 'r', 'LineWidth', 1.5);
plot(f3, avg_mag3, 'g', 'LineWidth', 1.5);

xlim([0 60]);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Average FFT for 12 Hz, 20 Hz, and 30 Hz Tasks');
legend('12 Hz Task', '20 Hz Task', '30 Hz Task');
grid on;

%% ===== Highlight frequencies using vertical lines + colored dots =====

baseFreqs = [6, 10, 15];     % 标 6 / 10 / 15 Hz
colors = {'b','r','g'};      
markerSize = 7;
maxY = max([avg_mag1 avg_mag2 avg_mag3]) * 1.03;
legendDots = gobjects(3,1);

for i = 1:length(baseFreqs)
    f0 = baseFreqs(i);
    color = colors{i};
    
    harmonics = f0 * (1:floor(60/f0));
    
    for hi = 1:length(harmonics)
        h = harmonics(hi);
        xline(h, '--k', 'LineWidth', 0.7, 'Alpha', 0.25);
        [~, idx1] = min(abs(f1 - h));
        [~, idx2] = min(abs(f2 - h));
        [~, idx3] = min(abs(f3 - h));
        yvals = [avg_mag1(idx1), avg_mag2(idx2), avg_mag3(idx3)];
        y = max(yvals);

        hDot = plot(h, y, 'o', ...
            'Color', color, ...
            'MarkerFaceColor', color, ...
            'MarkerSize', markerSize);
        if hi == 1
            legendDots(i) = hDot;
        end
    end
end


legend(legendDots, {'6 Hz harmonics', '10 Hz harmonics', '15 Hz harmonics'}, ...
    'Location', 'northwest');

plot_beta_topoplt(amp12, locFile,'12Hz');
plot_beta_topoplt(amp20, locFile,'20Hz');
plot_beta_topoplt(amp30, locFile,'30Hz');


%% ================== Question 3: Normalized SSVEP Detection ==================
disp("=== Running Question 3 for ALL FREQUENCIES ===");

intervalSec = 30;       
intervalSamples = intervalSec * fs;

% Pack all data & info into arrays for loop processing
allData = {data_12(2:9, idx_12), data_20(2:9, idx_20), data_30(2:9, idx_30)};
allMag  = {mag1_ch, mag2_ch, mag3_ch};
allF    = {f1, f2, f3};
freqList = [12, 20, 30];
colorList = {'b','r','g'};

figure; hold on;

for cond = 1:3
    eegData = allData{cond};
    targetFreq = freqList(cond);

    % Split into intervals
    totalSamples = size(eegData, 2);
    numIntervals = floor(totalSamples / intervalSamples);

    ssvepAmp = zeros(1, numIntervals);

    for i = 1:numIntervals
        seg = eegData(:, (i-1)*intervalSamples + 1 : i*intervalSamples);
        [f_tmp, mag_tmp] = compute_fft_each_channel(seg, fs);

        % find target frequency bin
        [~, idxF] = min(abs(f_tmp - targetFreq));
        ssvepAmp(i) = mean(mag_tmp(:, idxF));
    end

    % normalize
    normAmp = ssvepAmp / max(ssvepAmp);

    % x-axis durations
    durations = (1:numIntervals) * intervalSec;

    % plot curve
    plot(durations, normAmp, '-o', ...
        'Color', colorList{cond}, ...
        'LineWidth', 1.8, ...
        'MarkerSize', 7);

end

xlabel('Duration (s)');
ylabel('Normalized SSVEP Magnitude');
title('Normalized SSVEP Detection vs Duration for All Frequencies');
legend('12 Hz','20 Hz','30 Hz', 'Location', 'southeast');
grid on;
ylim([0 1.05]);













function [f, mag_ch] = compute_fft_each_channel(eeg, fs)
    [nCh, N] = size(eeg);
    fft_vals = fft(eeg, [], 2);
    fft_vals = fft_vals(:, 1:floor(N/2));
    mag_ch = abs(fft_vals);
    mag_ch(:,2:end) = 2 * mag_ch(:,2:end); 
    f = (0:floor(N/2)-1) * (fs/N);
end

function amps = extract_freq_amp(f, mag_ch, targetFreq)
    [~, idx] = min(abs(f - targetFreq)); 
    amps = mag_ch(:, idx);
end

function plot_beta_topoplt(data8, locFile, name)
    data16 = nan(16, size(data8,2));  
    data16(1,:)   = data8(1,:);  % Fz
    data16(6,:)   = data8(2,:);  % Cz
    data16(11,:)  = data8(4,:);  % Pz
    data16(12,:)  = data8(5,:);  % P4
    data16(13,:)  = data8(3,:);  % P3
    data16(14,:)  = data8(8,:);  % PO8
    data16(15,:)  = data8(6,:);  % PO7
    data16(16,:)  = data8(7,:);  % Oz

    vals = data16(:, :);
    clim = [min(vals(:)), max(vals(:))];

    figure;
    topoplot(data16(:, :), locFile, ...
             'maplimits', clim, ... 
             'electrodes', 'labels', ...
             'style', 'both');
    title(name);

    h = colorbar('eastoutside');
    h.Label.String = 'Amplitude (\muV)';
end
