function [time_data,signal_data,trigger_data,target_data]=split_data(eeg_signal,mode)
if (mode == 0)
    time_data = eeg_signal.y(1:1,:);
    signal_data = eeg_signal.y(2:9,:);
    trigger_data = eeg_signal.y(10:10,:);
    target_data = eeg_signal.y(11:11,:);
else
    time_data = eeg_signal(1:1,:);
    signal_data = eeg_signal(2:9,:);
    trigger_data = eeg_signal(10:10,:);
    target_data = eeg_signal(11:11,:);
end
end
