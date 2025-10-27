%% ==========================================================
% File: analyze_assr.m
% Purpose: 对 EEG 信号执行 ASSR 频域分析
% ==========================================================
clear; clc; close all;

load('EEG_recording.mat');  % 包含 EEG_data (channels x time) 和 flag

fs = 256;   % EEG采样率
[chN, N] = size(EEG_data);

% 1️⃣ 根据flag提取播放期间的数据
active_idx = find(flag == 1);
EEG_play = EEG_data(:, active_idx);

% 2️⃣ FFT分析
L = size(EEG_play, 2);
f = fs*(0:(L/2))/L;

EEG_fft = abs(fft(EEG_play, [], 2));
EEG_fft_mean = mean(EEG_fft(:, 1:L/2+1), 1);

% 3️⃣ 绘制频谱
figure;
plot(f, EEG_fft_mean);
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title('Average EEG spectrum during ASSR');
grid on; xlim([0 60]);

% 4️⃣ 计算归一化ASSR功率
EEG_fft_norm = EEG_fft_mean / sum(EEG_fft_mean);

% 5️⃣ 取40Hz或30Hz对应频点
f_mod = 40; % 改成30查看另一实验
k_mod = round(f_mod / fs * L);
ASSR_power = EEG_fft_norm(k_mod);
disp(['ASSR normalized magnitude at ' num2str(f_mod) ' Hz = ' num2str(ASSR_power)]);

% 6️⃣ 绘制累计时长曲线（30s步长）
durations = 30:30:600; % 最多10分钟
rel_mags = zeros(1, length(durations));
for i = 1:length(durations)
    nSamp = min(durations(i)*fs, size(EEG_play,2));
    seg_fft = mean(abs(fft(EEG_play(:,1:nSamp), [], 2)), 1);
    rel_mags(i) = seg_fft(round(f_mod / fs * nSamp)) / sum(seg_fft);
end
figure; plot(durations, rel_mags, '-o');
xlabel('Duration (s)'); ylabel('Normalized ASSR magnitude');
title('ASSR Strength vs. Recording Duration'); grid on;
