clc;clear;

Fs = 256;
raw_data = load('raw_data.mat'); 
lab_data = load('mean_data.mat');

time_sample = raw_data.y(1:1, 1300:end); 

raw_signal = raw_data.y(2:6, 1300:end); 
lab_signal = lab_data.y(2:2,1300:end);

envelopes = zeros(size(raw_signal));
disp(size(time_sample));

for i = 1:5
    envelopes(i, :) = envelope_detection(raw_signal(i, :), 8, 13, 1);
end
envelope_mean = mean(envelopes, 1); 

function_output = envelope_mean;
simulink_output = lab_signal;


total_length = length(function_output);
t_total = (0:total_length-1) / Fs;



length_window = 500;
len = length(time_sample); 


min_sum = Inf; 
min_idx = 1;
max_sum = -Inf; 
max_idx = 1;

for i = 1:(len - length_window)
    diff_window = abs(function_output(i:i+length_window) - simulink_output(i:i+length_window));
    sum_diff = sum(diff_window); 
    
    if sum_diff < min_sum
        min_sum = sum_diff;
        min_idx = i;
    end
    
    if sum_diff > max_sum
        max_sum = sum_diff;
        max_idx = i;
    end
end

fprintf("max_index: %d \n", max_idx);
fprintf("min_index: %d \n", min_idx);

figure('Position', [100, 100, 1200, 800]);

plot(time_sample, function_output, 'b-', 'LineWidth', 1, 'DisplayName', 'Function Output');
hold on;
plot(time_sample, simulink_output, 'r--', 'LineWidth', 1, 'DisplayName', 'Simulink Output');

y_lim = ylim;
y_min = y_lim(1);
y_max = y_lim(2);

start_t_max = time_sample(max_idx);
end_t_max = time_sample(max_idx + length_window);
rectangle('Position', [start_t_max, y_min, end_t_max - start_t_max, y_max - y_min], ...
          'FaceColor', 'red', ...
          'EdgeColor', 'none', ...
          'FaceAlpha', 0.2);

plot([start_t_max, start_t_max], [y_min, y_max], 'k--', 'LineWidth', 1.5);
plot([end_t_max, end_t_max], [y_min, y_max], 'k--', 'LineWidth', 1.5);

start_t_min = time_sample(min_idx);
end_t_min = time_sample(min_idx + length_window);
rectangle('Position', [start_t_min, y_min, end_t_min - start_t_min, y_max - y_min], ...
          'FaceColor', 'green', ...
          'EdgeColor', 'none', ...
          'FaceAlpha', 0.2);

plot([start_t_min, start_t_min], [y_min, y_max], 'k-.', 'LineWidth', 1.5);
plot([end_t_min, end_t_min], [y_min, y_max], 'k-.', 'LineWidth', 1.5);

% add label and legend
xlabel('Time(s)'); 
ylabel('Value');
legend('Function Output', 'Simulink Output', 'Maximum difference interval', 'Minimum difference interval');
grid on;
hold off;

% extract similar data
similar_start_idx = min_idx;
similar_end_idx = min_idx + length_window;
similar_time = time_sample(similar_start_idx:similar_end_idx);
similar_func = function_output(similar_start_idx:similar_end_idx);
similar_simu = simulink_output(similar_start_idx:similar_end_idx);

% extract distinct data
diff_start_idx = max_idx;
diff_end_idx = max_idx + length_window;
diff_time = time_sample(diff_start_idx:diff_end_idx);
diff_func = function_output(diff_start_idx:diff_end_idx);
diff_simu = simulink_output(diff_start_idx:diff_end_idx);

figure('Position', [100, 100, 1000, 600]);
plot(similar_time, similar_func, 'b-', 'LineWidth', 1.2, 'DisplayName', 'Function Output');
hold on;
plot(similar_time, similar_simu, 'r--', 'LineWidth', 1.2, 'DisplayName', 'Simulink Output');

title('Signals in a Period of High Similarity', 'FontSize', 14);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
legend('Location', 'best');
grid on;
box on;
hold off;

figure('Position', [200, 200, 1000, 600]);
plot(diff_time, diff_func, 'b-', 'LineWidth', 1.2, 'DisplayName', 'Function Output');
hold on;
plot(diff_time, diff_simu, 'r--', 'LineWidth', 1.2, 'DisplayName', 'Simulink Output');

title('Signals in a Period of Significant Difference', 'FontSize', 14);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
legend('Location', 'best');
grid on;
box on;
hold off;