clear; close all; clc;
Fs = 256;
t_start = 4.5;
t_end = 8;

data1 = load("Exp_1_Run_1.mat"); data2 = load("Exp_1_Run_2.mat");
data3 = load("Exp_1_Run_3.mat"); data4 = load("Exp_1_Run_4.mat"); 
classrun1 = load("classrun1.mat"); classrun2 = load("classrun2.mat");
classrun3 = load("classrun3.mat"); classrun4 = load("classrun4.mat");

% 4.5 - 8s (before CSP)
[left1, right1] = get_data(data1, classrun1, t_start-2.5, t_end-2.5);
[left2, right2] = get_data(data2, classrun2, t_start-2.5, t_end-2.5);
[left3, right3] = get_data(data3, classrun3, t_start-2.5, t_end-2.5);
[left4, right4] = get_data(data4, classrun4, t_start-2.5, t_end-2.5);

left_data = [left1, left2, left3, left4];
right_data = [right1, right2, right3, right4];

N_left  = numel(left_data);
N_right = numel(right_data);

figure;
bar([N_left, N_right]);
set(gca, 'XTickLabel', {'Left', 'Right'});
ylabel('Number of Segments (N)');
title('Segment Count for Left vs Right');

P_left = get_power(left_data,200); P_right = get_power(right_data,200);
P_left = data_process(P_left); P_right = data_process(P_right);
plot_power(P_left,P_right)

%Part 2
[left_meanPower, lpl] = power_by_channel(left_data);
[right_meanPower, rpl] = power_by_channel(right_data);

plot_diff_topo(left_meanPower, right_meanPower, 'BCI.locs')

function [t_start, t_end] = align_data(data, idx, ts, te)
    time = data.y(1,:); 
    t_idx = time(idx);
    t_start = t_idx + ts; t_end = t_idx + te;
end

function [left, right] = get_idx(data, classrun)
    trigger = data.y(18,:);
    idx = find(trigger(1:end-1) == 1 & trigger(2:end) == 0);
    fname = fieldnames(classrun);
    labels = classrun.(fname{1});  
    left  = idx(labels(1,:) == 1);
    right = idx(labels(2,:) == 1);

end

function segments = segment_data(data, t_start, t_end)
    time = data.y(1,:); 
    signal = data.y(2:17,:); 
    Fs = 256;                    
    low_cut  = 8;
    high_cut = 20;
    
    bpFilt = designfilt('bandpassfir', ...
                        'FilterOrder', 300, ...
                        'CutoffFrequency1', low_cut, ...
                        'CutoffFrequency2', high_cut, ...
                        'SampleRate', Fs);
    
    signal_filt = filtfilt(bpFilt, double(signal') )';  
    numSeg = length(t_start);
    segments = cell(1, numSeg);  
    
    for i = 1:numSeg
        idx = find(time >= t_start(i) & time <= t_end(i));
        segments{i} = signal_filt(:, idx);
    end
end

function [segments_left, segments_right] = get_data(data, classrun, ts, te)
    [left, right] = get_idx(data, classrun);
    % left
    [t_start, t_end] = align_data(data, left, ts, te);
    segments_left = segment_data(data, t_start, t_end);
    % right
    [t_start, t_end] = align_data(data, right, ts, te);
    segments_right = segment_data(data, t_start, t_end);
    
end

function P = get_power(all_segments, threshold)

    numSeg = length(all_segments);
    P = zeros(1, numSeg);

    for i = 1:numSeg
        sig = all_segments{i};   
        sig(abs(sig) > threshold) = NaN;
        P(i) = mean(sig(:).^2, 'omitnan');
        if isnan(P(i))
            P(i) = NaN;  
        end
    end
end

function processed_data = data_process(data)
    processed_data = data;
    processed_data(data > 200) = NaN;
end

function plot_power(P_left,P_right)

    nan_left  = isnan(P_left);
    nan_right = isnan(P_right);

    P_left_plot  = P_left;
    P_right_plot = P_right;

    for i = 1:length(P_left)
        if nan_left(i)
            if i==1
                P_left_plot(i) = P_left(i+1);
            elseif i==length(P_left)
                P_left_plot(i) = P_left(i-1);
            else
                P_left_plot(i) = mean([P_left(i-1), P_left(i+1)], "omitnan");
            end
        end
        if nan_right(i)
            if i==1
                P_right_plot(i) = P_right(i+1);
            elseif i==length(P_right)
                P_right_plot(i) = P_right(i-1);
            else
                P_right_plot(i) = mean([P_right(i-1), P_right(i+1)], "omitnan");
            end
        end
    end

    figure; hold on;
    plot(P_left_plot,  'b-o', 'LineWidth', 1.5);
    plot(P_right_plot, 'g-o', 'LineWidth', 1.5);

    x_nan_left = find(nan_left);
    plot(x_nan_left, P_left_plot(x_nan_left), 'rx', 'MarkerSize', 12, 'LineWidth', 2);

    x_nan_right = find(nan_right);
    plot(x_nan_right, P_right_plot(x_nan_right), 'rx', 'MarkerSize', 12, 'LineWidth', 2);

    for i = x_nan_left
        plot(i, P_left_plot(i), 'rx', 'MarkerSize', 12, 'LineWidth', 2);
    end
    for i = x_nan_right
        plot(i, P_right_plot(i), 'rx', 'MarkerSize', 12, 'LineWidth', 2);
    end

    legend('Left','Right','NaN points');
    xlabel('Segment #');
    ylabel('Power');
    title('Average Power with NaN markers');
    hold off;
end

function [meanPower, pow_list_all] = power_by_channel(data)
    numTrials = numel(data);
    numCh = size(data{1}, 1);

    meanPower = zeros(numCh,1);  
    pow_list_all = cell(numCh,1);  

    for ch = 1:numCh
        pow_list = zeros(numTrials,1);

        for t = 1:numTrials
            x = data{t}(ch, :);       
            pow_list(t) = mean(x.^2);
        end

        pow_list_all{ch} = pow_list;
        valid_idx = pow_list <= 200;     
        pow_valid = pow_list(valid_idx); 
        if isempty(pow_valid)
            meanPower(ch) = NaN;  
        else
            meanPower(ch) = mean(pow_valid);
        end
    end
end

function plot_diff_topo(left_meanPower, right_meanPower, locfile)
    diffPower = right_meanPower - left_meanPower;
    figure;
    topoplot(diffPower, locfile);
    title('Right - Left Mean Power');
    colorbar;

end

