clear;clc;
eeg_signal = load('F:\Documents\GitHub\CU_BCI_Lab\HW\HW_4_zg2567\Data\train1_group1_section2.mat');

time_data = eeg_signal.y(1:1,:);
signal_data = eeg_signal.y(2:9,:);
trigger_data = eeg_signal.y(10:10,:);
target_data = eeg_signal.y(11:11,:);

%signal_data = remove_artifacts(signal_data);

[non_target_index, target_index] = trigger_alignment(trigger_data,target_data);

ERP_non_target = ERP_calculate(non_target_index,signal_data);
ERP_target = ERP_calculate(target_index,signal_data);

ERP_plot_all(ERP_target,'ERP of Target Characters of All Electrodes');
ERP_plot_all(ERP_non_target,'ERP of Non-target Characters of All Electrodes');

mean_ERP_non_target = mean(ERP_non_target); 
mean_ERP_target = mean(ERP_target); 

ERP_plot_mean(mean_ERP_target, mean_ERP_non_target);

ERP_plot_diff(mean_ERP_target-mean_ERP_non_target);
