clear;clc;
% Written bt Gustav Guo (zg2567)
% To run this code on your own workspace
% please remember to change the path info in Constants.m

eegDataManager = EEGDataManager(-300,450,256);
plotManager = PlotManager(-300,450,256,true,true);
wsModelManager = WithinSubjectModelManager();

% load dataset
[~,train1_signal_cross,train1_flash_cross,train1_target_cross] = eegDataManager.get_data_part2(Constants.TRAIN1_nomygroup_path);
[~,train2_signal_cross,train2_flash_cross,train2_target_cross] = eegDataManager.get_data_part2(Constants.TRAIN2_nomygroup_path);
[~,test1_signal_cross,test1_flash_cross,test1_target_cross] = eegDataManager.get_data_part2(Constants.TEST1_nomygroup_path);
[~,test2_signal_cross,test2_flash_cross,test2_target_cross] = eegDataManager.get_data_part2(Constants.TEST2_nomygroup_path);

%cut data clip with target and flash pulse
[idxtrain1_non_target, idxtrain1_target] = eegDataManager.trigger_alignment(train1_flash_cross,train1_target_cross);
[idxtrain2_non_target, idxtrain2_target] = eegDataManager.trigger_alignment(train2_flash_cross,train2_target_cross);
[idxtest1_non_target, idxtest1_target] = eegDataManager.trigger_alignment(test1_flash_cross,test1_target_cross);
[idxtest2_non_target, idxtest2_target] = eegDataManager.trigger_alignment(test2_flash_cross,test2_target_cross);


%[train1_ERP_non_target,train1_ERP_target,train1_mean_ERP_non_target,train1_mean_ERP_target] = eegDataManager.get_mean_ERP(idxtrain1_non_target,idxtrain1_target,train1_signal_cross); 
%plotManager.plot_mean_ERP(train1_mean_ERP_non_target,train1_mean_ERP_target,'train1_mean_ERP_task2 300');
%plotManager.plot_scalp_maps(train1_ERP_target,Constants.bci_locs_path,'train1_target_topoplot_task2 300');
%plotManager.plot_scalp_maps(train1_ERP_non_target,Constants.bci_locs_path,'train1_non_target_topoplot_task2 300');

%[train2_ERP_non_target,train2_ERP_target,train2_mean_ERP_non_target,train2_mean_ERP_target] = eegDataManager.get_mean_ERP(idxtrain2_non_target,idxtrain2_target,train2_signal_cross); 
%plotManager.plot_mean_ERP(train2_mean_ERP_non_target,train2_mean_ERP_target,'train2_mean_ERP_task2 300');
%plotManager.plot_scalp_maps(train2_ERP_target,Constants.bci_locs_path,'train2_target_topoplot_task2 300');
%plotManager.plot_scalp_maps(train2_ERP_non_target,Constants.bci_locs_path,'train2_non_target_topoplot_task2 300');


train1_tuple = {idxtrain1_target, idxtrain1_non_target, train1_signal_cross};
train2_tuple = {idxtrain2_target, idxtrain2_non_target, train2_signal_cross};
test1_tuple = {idxtest1_target,idxtest1_non_target,test1_signal_cross};
test2_tuple = {idxtest2_target,idxtest2_non_target,test2_signal_cross};

% all the data needed
[X_train1_cross,Y_train1_cross,X_test1_cross,Y_test1_cross] = eegDataManager.get_dataset(train1_tuple,test1_tuple,true);
[X_train2_cross,Y_train2_cross,X_test2_cross,Y_test2_cross] = eegDataManager.get_dataset(train2_tuple,test2_tuple,true);
X_trainall_cross = [X_train1_cross;X_train2_cross];
Y_trainall_cross = [Y_train1_cross;Y_train2_cross];
X_testall_cross = [X_test1_cross;X_test2_cross];
Y_testall_cross = [Y_test1_cross;Y_test2_cross];

% load dataset
[~,train1_signal,train1_flash,train1_target] = eegDataManager.get_data(Constants.train1_path);
[~,train2_signal,train2_flash,train2_target] = eegDataManager.get_data(Constants.train2_path);
[~,test1_signal,test1_flash,test1_target] = eegDataManager.get_data(Constants.test1_path);
[~,test2_signal,test2_flash,test2_target] = eegDataManager.get_data(Constants.test2_path);


%cut data clip with target and flash pulse
[idxtrain1_non_target, idxtrain1_target] = eegDataManager.trigger_alignment(train1_flash,train1_target);
[idxtrain2_non_target, idxtrain2_target] = eegDataManager.trigger_alignment(train2_flash,train2_target);
[idxtest1_non_target, idxtest1_target] = eegDataManager.trigger_alignment(test1_flash,test1_target);
[idxtest2_non_target, idxtest2_target] = eegDataManager.trigger_alignment(test2_flash,test2_target);


[train1_ERP_non_target,train1_ERP_target,train1_mean_ERP_non_target,train1_mean_ERP_target] = eegDataManager.get_mean_ERP(idxtrain1_non_target,idxtrain1_target,train1_signal); 
%plotManager.plot_mean_ERP(train1_mean_ERP_non_target,train1_mean_ERP_target,'train1_mean_ERP');
%plotManager.plot_scalp_maps(train1_ERP_target,Constants.bci_locs_path,'train1_target_topoplot');
%plotManager.plot_scalp_maps(train1_ERP_non_target,Constants.bci_locs_path,'train1_non_target_topoplot');

[train2_ERP_non_target,train2_ERP_target,train2_mean_ERP_non_target,train2_mean_ERP_target] = eegDataManager.get_mean_ERP(idxtrain2_non_target,idxtrain2_target,train2_signal); 
%plotManager.plot_mean_ERP(train2_mean_ERP_non_target,train2_mean_ERP_target,'train2_mean_ERP');
%plotManager.plot_scalp_maps(train2_ERP_target,Constants.bci_locs_path,'train2_target_topoplot');
%plotManager.plot_scalp_maps(train2_ERP_non_target,Constants.bci_locs_path,'train2_non_target_topoplot');


train1_tuple = {idxtrain1_target, idxtrain1_non_target, train1_signal};
train2_tuple = {idxtrain2_target, idxtrain2_non_target, train2_signal};
test1_tuple = {idxtest1_target,idxtest1_non_target,test1_signal};
test2_tuple = {idxtest2_target,idxtest2_non_target,test2_signal};

% all the data needed
[X_train1,Y_train1,X_test1,Y_test1] = eegDataManager.get_dataset(train1_tuple,test1_tuple,false);
[X_train2,Y_train2,X_test2,Y_test2] = eegDataManager.get_dataset(train2_tuple,test2_tuple,false);
X_trainall = [X_train1;X_train2];
Y_trainall = [Y_train1;Y_train2];
X_testall = [X_test1;X_test2];
Y_testall = [Y_test1;Y_test2];

combinations = {
    % 1. Cross-subject model, test on Group1
    {'Cross-Subject Model', X_trainall_cross, Y_trainall_cross, 'Group1 Test', X_testall, Y_testall}

    % 2. Cross-subject model, test on all other groups
    {'Cross-Subject Model', X_trainall_cross, Y_trainall_cross, 'All Other Groups Test', X_testall_cross, Y_testall_cross}

    % 3. Within-subject model, test on Group1
    {'Within-Subject Model', X_trainall, Y_trainall, 'Group1 Test', X_testall, Y_testall}

    % 4. Within-subject model, test on all other groups
    {'Within-Subject Model', X_trainall, Y_trainall, 'All Other Groups Test', X_testall_cross, Y_testall_cross}
};


numCombinations = numel(combinations);
results = cell(numCombinations, 1);
models = cell(numCombinations, 1);

for i = 1:numCombinations
    c = combinations{i};
    name = [c{1}, ' & ', c{4}];
    dataset = {c{2}, c{3}, c{5}, c{6}};
    
    [result, mdl] = wsModelManager.model_train_evaluate(dataset, 'logistic', name);
    results{i} = result;
    models{i} = mdl;
    
    if i == 1
        best_beta = mdl.Beta;
        best_acc = result.acc;
        best_idx = 1;
   % elseif result.acc > best_acc
   %     best_beta = mdl.Beta;
   %     best_acc = result.acc;
    %    best_idx = i;
    end
end

plotManager.plot_all_model_results(results, combinations);

disp(['Best model index (task2): ', num2str(best_idx)]);


best_weights = reshape(best_beta,8,eegDataManager.before_sample+eegDataManager.after_sample+1);
%topoplot of the average squared weights over time
powerofweights = mean(best_weights.^2,2);
plotManager.plot_beta_topoplt(powerofweights,Constants.bci_locs_path,'topoplot of the average squared weights over time (task2) 300');

%topoplot of the average squared weights over telectrodes
powerofweights = mean(best_weights.^2,1);
plotManager.plot_beta_line(powerofweights,(train1_mean_ERP_target+train2_mean_ERP_target)/2,'topoplot of the average squared weights over telectrodes (task2) 300');

time = linspace(-plotManager.before_time, plotManager.after_time, length(powerofweights));
[max_corr, best_time, corr_vals, time_corr] = wsModelManager.find_best_correlation(powerofweights, (train1_mean_ERP_target + train2_mean_ERP_target) / 2, time, 20);
fprintf('Max correspond = %.3f, time = %.1f ms\n', max_corr, best_time);
plotManager.plot_corr(time_corr,corr_vals,best_time,max_corr,'Sliding correlation between Power of Weights and Mean ERP (task2) 300');
