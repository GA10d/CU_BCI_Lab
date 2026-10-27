folder = 'F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Data';

TEST1 = [];
TEST2 = [];
TRAIN1 = [];
TRAIN2 = [];

for y = 1:7
    files = {
        sprintf('test1_group%d_Thursday.mat', y), ...
        sprintf('test1_group%d_Tuesday.mat',  y)
    };
    for f = files
        file = fullfile(folder, f{1});
        if exist(file, 'file')
            tmp = load(file);
            TEST1 = [TEST1, tmp.y];
        end
    end

    files = {
        sprintf('test2_group%d_Thursday.mat', y), ...
        sprintf('test2_group%d_Tuesday.mat',  y)
    };
    for f = files
        file = fullfile(folder, f{1});
        if exist(file, 'file')
            tmp = load(file);
            TEST2 = [TEST2, tmp.y];
        end
    end

    files = {
        sprintf('train1_group%d_Thursday.mat', y), ...
        sprintf('train1_group%d_Tuesday.mat',  y)
    };
    for f = files
        file = fullfile(folder, f{1});
        if exist(file, 'file')
            tmp = load(file);
            TRAIN1 = [TRAIN1, tmp.y];
        end
    end

    files = {
        sprintf('train2_group%d_Thursday.mat', y), ...
        sprintf('train2_group%d_Tuesday.mat',  y)
    };
    for f = files
        file = fullfile(folder, f{1});
        if exist(file, 'file')
            tmp = load(file);
            TRAIN2 = [TRAIN2, tmp.y];
        end
    end
end

save(fullfile(folder,'Merged_TEST1.mat'), 'TEST1');
save(fullfile(folder,'Merged_TEST2.mat'), 'TEST2');
save(fullfile(folder,'Merged_TRAIN1.mat'), 'TRAIN1');
save(fullfile(folder,'Merged_TRAIN2.mat'), 'TRAIN2');

disp('Data Cat Finished');
