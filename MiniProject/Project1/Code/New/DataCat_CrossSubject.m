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

        if contains(f{1}, 'group1_Thursday')
            continue;
        end

        if exist(file, 'file')
            tmp = load(file);
            fn = fieldnames(tmp);
            TEST1 = [TEST1, tmp.(fn{1})];
        end
    end

    files = {
        sprintf('test2_group%d_Thursday.mat', y), ...
        sprintf('test2_group%d_Tuesday.mat',  y)
    };
    for f = files
        file = fullfile(folder, f{1});

        if contains(f{1}, 'group1_Thursday')
            continue;
        end

        if exist(file, 'file')
            tmp = load(file);
            fn = fieldnames(tmp);
            TEST2 = [TEST2, tmp.(fn{1})];
        end
    end

    files = {
        sprintf('train1_group%d_Thursday.mat', y), ...
        sprintf('train1_group%d_Tuesday.mat',  y)
    };
    for f = files
        file = fullfile(folder, f{1});

        if contains(f{1}, 'group1_Thursday')
            continue;
        end

        if exist(file, 'file')
            tmp = load(file);
            fn = fieldnames(tmp);
            TRAIN1 = [TRAIN1, tmp.(fn{1})];
        end
    end

    files = {
        sprintf('train2_group%d_Thursday.mat', y), ...
        sprintf('train2_group%d_Tuesday.mat',  y)
    };
    for f = files
        file = fullfile(folder, f{1});

        if contains(f{1}, 'group1_Thursday')
            continue;
        end

        if exist(file, 'file')
            tmp = load(file);
            fn = fieldnames(tmp);
            TRAIN2 = [TRAIN2, tmp.(fn{1})];
        end
    end
end

save(fullfile(folder,'Merged_TEST1_nomygroup.mat'), 'TEST1');
save(fullfile(folder,'Merged_TEST2_nomygroup.mat'), 'TEST2');
save(fullfile(folder,'Merged_TRAIN1_nomygroup.mat'), 'TRAIN1');
save(fullfile(folder,'Merged_TRAIN2_nomygroup.mat'), 'TRAIN2');

