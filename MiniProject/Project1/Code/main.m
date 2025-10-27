clear;clc;
bci_locs_path = 'F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Data\BCI.locs';
train1 = load('F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Data\train1_group1_section2.mat');
test1 = load('F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Data\test1_group1_section2.mat');
train2 = load('F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Data\train2_group1_section2.mat');
test2 = load('F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Data\test2_group1_section2.mat');

[train1_time,train1_signal,train1_flash,train1_target]=split_data(train1,0);
[train2_time,train2_signal,train2_flash,train2_target]=split_data(train2,0); 
[test1_time,test1_signal,test1_flash,test1_target]=split_data(test1,0);
[test2_time,test2_signal,test2_flash,test2_target]=split_data(test2,0);

[idxtrain1_non_target, idxtrain1_target] = trigger_alignment(train1_flash,train1_target);
[idxtrain2_non_target, idxtrain2_target] = trigger_alignment(train2_flash,train2_target);
[idxtest1_non_target, idxtest1_target] = trigger_alignment(test1_flash,test1_target);
[idxtest2_non_target, idxtest2_target] = trigger_alignment(test2_flash,test2_target);

%Task 1
[train1_ERP_non_target,train1_ERP_target,train1_mean_ERP_non_target,train1_mean_ERP_target] = get_mean_ERP(idxtrain1_non_target,idxtrain1_target,train1_signal,1,'train1_mean_ERP'); 
plot_scalp_maps(train1_ERP_target,bci_locs_path,'train1_target_topoplot');
plot_scalp_maps(train1_ERP_non_target,bci_locs_path,'train1_non_target_topoplot');

[train2_ERP_non_target,train2_ERP_target,train2_mean_ERP_non_target,train2_mean_ERP_target] = get_mean_ERP(idxtrain2_non_target,idxtrain2_target,train2_signal,1,'train2_mean_ERP'); 
plot_scalp_maps(train2_ERP_target,bci_locs_path,'train2_target_topoplot');
plot_scalp_maps(train2_ERP_non_target,bci_locs_path,'train2_non_target_topoplot');

train1_tuple = {idxtrain1_target, idxtrain1_non_target, train1_signal};
train2_tuple = {idxtrain2_target, idxtrain2_non_target, train2_signal};
test1_tuple = {idxtest1_target,idxtest1_non_target,test1_signal};
test2_tuple = {idxtest2_target,idxtest2_non_target,test2_signal};


% train1+test1
[X_train1,Y_train1,X_test1,Y_test1] = get_dataset(train1_tuple,test1_tuple,false);
[X_train2,Y_train2,X_test2,Y_test2] = get_dataset(train2_tuple,test2_tuple,false);
X_trainall = [X_train1;X_train2];
Y_trainall = [Y_train1;Y_train2];
X_testall = [X_test1;X_test2];
Y_testall = [Y_test1;Y_test2];

% train1+test1
dataset = {X_train1,Y_train1,X_test1,Y_test1};
model_train_evaluate(dataset,'logistic','train1 & test1');
% train1+test2
dataset = {X_train1,Y_train1,X_test2,Y_test2};
model_train_evaluate(dataset,'logistic','train1 & test2');
% train1+test1+2
dataset = {X_train1,Y_train1,X_testall,Y_testall};
model_train_evaluate(dataset,'logistic','train1 & test1+2');

% train2+test1
dataset = {X_train2,Y_train2,X_test1,Y_test1};
model_train_evaluate(dataset,'logistic','train2 & test1');
% train2+test2
dataset = {X_train2,Y_train2,X_test2,Y_test2};
model_train_evaluate(dataset,'logistic','train2 & test2');
% train2+test1+2
dataset = {X_train2,Y_train2,X_testall,Y_testall};
model_train_evaluate(dataset,'logistic','train2 & test1+2');

%train1+2 test1
dataset = {X_trainall,Y_trainall,X_test1,Y_test1};
model_train_evaluate(dataset,'logistic','train1+2 & test1');
%train1+2 test2
dataset = {X_trainall,Y_trainall,X_test2,Y_test2};
model_train_evaluate(dataset,'logistic','train1+2 & test2');
%train1+2 test1+2
dataset = {X_trainall,Y_trainall,X_testall,Y_testall};
model_train_evaluate(dataset,'logistic','train1+2 & test1+2');