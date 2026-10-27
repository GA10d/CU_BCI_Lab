clear; clc;
folder = 'F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Data';

% 每个要检查的文件名模式
patterns = {
    'test1_group%d_Thursday.mat'
    'test1_group%d_Tuesday.mat'
    'test2_group%d_Thursday.mat'
    'test2_group%d_Tuesday.mat'
    'train1_group%d_Thursday.mat'
    'train1_group%d_Tuesday.mat'
    'train2_group%d_Thursday.mat'
    'train2_group%d_Tuesday.mat'
};

for y = 1:7
    for p = 1:length(patterns)
        filename = sprintf(patterns{p}, y);
        file = fullfile(folder, filename);

        if exist(file, 'file')
            disp(['Loading: ' file]);

            tmp = load(file);

            % 如果变量不是叫 y，则自动找到唯一的数据变量
            if isfield(tmp, 'y')
                eeg = tmp.y;
            else
                vars = fieldnames(tmp);
                eeg = tmp.(vars{1}); % 默认第一项
                disp(['  (Using variable: ' vars{1} ')']);
            end

            % Plot
            figure('Name', filename, 'NumberTitle', 'off');
            plot(eeg'); % 如果是 channels × samples，这里用转置
            xlabel('Samples');
            ylabel('Amplitude');
            title(['EEG Signal: ' filename]);
            grid on;

            % 可选：暂停，按任意键看下一个
            disp('Press any key to continue to next file...');
            pause;
        end
    end
end
