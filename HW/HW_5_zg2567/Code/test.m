clear;clc;
eloc_file = 'F:\Documents\GitHub\CU_BCI_Lab\HW\HW_5_zg2567\Code\BCI.locs';
fs = 256;

[exp1_data,exp2_data,exp1_flag,exp2_flag] = load_data();

[exp1_time_start, exp1_time_end] = get_index(exp1_flag.Y);
[exp2_time_start, exp2_time_end] = get_index(exp2_flag.Y);

exp1_eeg = align_data(exp1_data.Y,exp1_time_start, exp1_time_end);
exp2_eeg = align_data(exp2_data.Y,exp2_time_start, exp2_time_end);

[mag1,f1,mag2,f2] = fft_analize(exp1_eeg,exp2_eeg,false);
[mag1_os,mag2_os,mag1_f,mag2_f,idx1, idx2] = one_sided_spectrum(mag1,mag2,fs,false);

[value1_r,value1_a] = get_power(mag1_os, idx1);
[value2_r,value2_a] = get_power(mag2_os, idx2);


max_duration_sec = exp1_time_end - exp1_time_start; % both trails last 600 seconds
%time_evaluation (max_duration_sec,exp1_eeg,exp2_eeg,fs);
%time_evaluation_band(max_duration_sec,exp1_eeg,exp2_eeg,fs);

scalp_assr(exp1_eeg,900,40,eloc_file);
scalp_assr(exp2_eeg,900,30,eloc_file);




function [exp1_data,exp2_data,exp1_flag,exp2_flag] = load_data()
    exp1_data = load("F:\Documents\GitHub\CU_BCI_Lab\HW\HW_5_zg2567\Data\data1_eeg.mat");
    exp2_data = load("F:\Documents\GitHub\CU_BCI_Lab\HW\HW_5_zg2567\Data\data2_eeg.mat");
    exp1_flag = load("F:\Documents\GitHub\CU_BCI_Lab\HW\HW_5_zg2567\Data\data1_sound.mat");
    exp2_flag = load("F:\Documents\GitHub\CU_BCI_Lab\HW\HW_5_zg2567\Data\data2_sound.mat");
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
    aligned_data = signal(2:end-1, idx); %last channel is all zero
end

function [mag1,f1,mag2,f2] = fft_analize(data1, data2, skip_flag)

    fs = 256;
    function [avg_mag_full, avg_phase_full, f_full] = get_full_fft(data, fs)
        [~, N] = size(data);
        Y = fft(data, [], 2);  % Full FFT result
        avg_mag_full = mean(abs(Y), 1);
        avg_phase_full = mean(angle(Y), 1);
        f_full = (-N/2:(N/2)-1) * fs / N;
        avg_mag_full = fftshift(avg_mag_full);
        avg_phase_full = fftshift(avg_phase_full);
    end

    [mag1, phase1, f1] = get_full_fft(data1, fs);
    [mag2, phase2, f2] = get_full_fft(data2, fs);
    
    if skip_flag
        disp('skip plot');
        return
    end

    figure;
    subplot(4,1,1);
    plot(f1, mag1, 'LineWidth', 1.5);
    xlim([-50 50]);
    title('Data1 - Magnitude (Full FFT)');
    ylabel('|X(f)|');
    grid on;
    subplot(4,1,2);
    plot(f1, phase1, 'LineWidth', 1.5);
    xlim([-50 50]);
    ylabel('\angle X(f)');
    title('Data1 - Phase');
    grid on;
    subplot(4,1,3);
    plot(f2, mag2, 'LineWidth', 1.5);
    xlim([-50 50]);
    ylabel('|X(f)|');
    title('Data2 - Magnitude (Full FFT)');
    grid on;
    subplot(4,1,4);
    plot(f2, phase2, 'LineWidth', 1.5);
    xlim([-50 50]);
    xlabel('Frequency (Hz)');
    ylabel('\angle X(f)');
    title('Data2 - Phase');
    grid on;
    exportgraphics(gcf,'fft_full_analysis.png','Resolution',300);
end

function [M1,M2,f1,f2,idx40,idx30] = one_sided_spectrum(mag1, mag2, fs, skip_flag)

    N1 = length(mag1);
    N2 = length(mag2);

    half1 = floor(N1/2) + 1;
    half2 = floor(N2/2) + 1;

    M1 = mag1(half1:end); 
    M2 = mag2(half2:end);

    M1 = abs(M1);
    M2 = abs(M2);

    M1(2:end-1) = 2 * M1(2:end-1);
    M2(2:end-1) = 2 * M2(2:end-1);

    f1 = (0:length(M1)-1) * fs / N1;
    f2 = (0:length(M2)-1) * fs / N2;

    [~, idx40] = min(abs(f1 - 40));
    [~, idx30] = min(abs(f2 - 30));

    if ~skip_flag
        figure; hold on;
        plot(f1, M1, 'LineWidth',1.5);
        plot(f2, M2, 'LineWidth',1.5);
        text(f1(idx40), M1(idx40), ' \leftarrow 40 Hz', 'FontSize',12);
        text(f2(idx30), M2(idx30), ' \leftarrow 30 Hz', 'FontSize',12);
        legend('40 Hz signal','30 Hz signal');
        xlim([0 50]);
        title('Single-Sided Magnitude Spectrum');
        grid on;
    end
end

function [relative_value, abs_value] = get_power(M, idx)
    abs_value = M(idx);
    relative_value = abs_value/sum(M);
end

function time_evaluation_band(max_duration_sec,exp1_eeg,exp2_eeg,fs)

    durations = 30:30:max_duration_sec;
    len_duration = length(durations);
    
    snr_30hz = zeros(1,len_duration);
    snr_40hz = zeros(1,len_duration);
    
    for i = 1:len_duration
        len1 = min(size(exp1_eeg,2), durations(i)*fs);
        len2 = min(size(exp2_eeg,2), durations(i)*fs);
    
        x40 = exp1_eeg(:,1:len1);  % 40 Hz signal
        x30 = exp2_eeg(:,1:len2);  % 30 Hz signal
    
        snr_40hz(i) = compute_freq_snr(x40, fs, 40);
        snr_30hz(i) = compute_freq_snr(x30, fs, 30);
    end
    
    figure('Units','normalized','OuterPosition',[0 0 1 1]);
    subplot(2,1,1);
    plot(durations, snr_40hz,'-o','LineWidth',1.5);
    grid on;
    title('ASSR SNR vs Duration (40 Hz)');
    xlabel('Duration (s)');
    ylabel('SNR (dB)');
    
    subplot(2,1,2);
    plot(durations, snr_30hz,'-o','LineWidth',1.5);
    grid on;
    title('ASSR SNR vs Duration (30 Hz)');
    xlabel('Duration (s)');
    ylabel('SNR (dB)');
    
    sgtitle('Frequency-domain SNR for ASSR');
    
    exportgraphics(gcf,'ASSR_SNR_Duration.png','Resolution',300);

end

function time_evaluation (max_duration_sec,exp1_eeg,exp2_eeg,fs)
    
    durations = 30:30:max_duration_sec;
    len_duration = length(durations);
    
    valuer_30hz=zeros(1, len_duration); valuea_30hz=zeros(1, len_duration); 
    valuer_40hz=zeros(1, len_duration); valuea_40hz=zeros(1, len_duration);
    
    for i = 1:len_duration
        [mag1,f1,mag2,f2] = fft_analize(exp1_eeg(:,1:durations(i)*fs),exp2_eeg(:,1:durations(i)*fs),true);
        [mag1_os,mag2_os,mag1_f,mag2_f,idx1, idx2] = one_sided_spectrum(mag1,mag2,fs,true);
        [value1_r,value1_a] = get_power(mag1_os, idx1);
        [value2_r,value2_a] = get_power(mag2_os, idx2);
        valuer_30hz(i) = value2_r; valuea_30hz(i) = value2_a;
        valuer_40hz(i) = value1_r; valuea_40hz(i) = value1_a;
    end
    
    figure('Units','normalized','OuterPosition',[0 0 1 1]); 
    subplot(2,2,1);
    plot(durations, valuer_30hz, '-o', 'LineWidth',1.5);
    title('30 Hz - Relative Power');
    xlabel('Duration (s)');
    ylabel('Relative Power');
    grid on;
    
    subplot(2,2,2);
    plot(durations, valuea_30hz, '-o', 'LineWidth',1.5);
    title('30 Hz - Absolute Power');
    xlabel('Duration (s)');
    ylabel('Absolute Power');
    grid on;
    
    subplot(2,2,3);
    plot(durations, valuer_40hz, '-o', 'LineWidth',1.5);
    title('40 Hz - Relative Power');
    xlabel('Duration (s)');
    ylabel('Relative Power');
    grid on;
    
    subplot(2,2,4);
    plot(durations, valuea_40hz, '-o', 'LineWidth',1.5);
    title('40 Hz - Absolute Power');
    xlabel('Duration (s)');
    ylabel('Absolute Power');
    grid on;
    
    sgtitle('ASSR Magnitude vs Duration'); 
    
    drawnow;
    exportgraphics(gcf,'ASSR_Duration_All.png','Resolution',300);

end

function scalp_assr(data, fs, fm, eloc_file)

    [~, numSamples] = size(data);
    Y = fft(data, [], 2);
    magY = abs(Y);
    half = floor(numSamples/2);
    magY = magY(:,1:half);
    freq_axis = linspace(0, fs/2, half);
    [~, fm_idx] = min(abs(freq_axis - fm));
    assr_mag = magY(:, fm_idx);
    assr_norm = assr_mag / sum(assr_mag);
    assr_norm = expand_to_16ch(assr_norm);
    figure;
    topoplot(assr_norm, eloc_file, ...
        'maplimits', 'maxmin', 'style', 'both', 'electrodes', 'on');
    title(sprintf('topoplot %d Hz', fm));
    colorbar;
    exportgraphics(gcf,['topoplot ',num2str(fm) ,'.png'],'Resolution',300);

end

function data16 = expand_to_16ch(data7)
    new_order = [ ...
        1, 5, 4, 0, 0, 2, ...
        6, 7, 0, 0, 3, ...
        0, 0, 0, 0, 0]; 

    numSamples = size(data7,2);
    data16 = nan(16, numSamples);

    for i = 1:16
        if new_order(i) > 0
            data16(i,:) = data7(new_order(i),:);
        end
    end
end


function snr_db = compute_freq_snr(signal, fs, fm)
    if size(signal,1) > 1
        x = mean(signal,1);
    else
        x = signal;
    end
    [pxx, f] = pwelch(x, hamming(1024), [], [], fs);

    [~, idx] = min(abs(f - fm));
    target_power = pxx(idx);
    noise_bins = [idx-3:idx-1, idx+1:idx+3];
    noise_bins(noise_bins < 1 | noise_bins > length(pxx)) = [];
    noise_floor = mean(pxx(noise_bins));
    snr_db = 10 * log10(target_power / noise_floor);
end
