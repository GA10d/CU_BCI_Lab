load('Lab2_Experiment1.mat'); 

signal_data = P_C_S.data;
disp(['Data Dimension: ', num2str(size(signal_data))]);

fs = P_C_S.samplingfrequency;
disp(['Sampling frequency：', num2str(fs), ' Hz']);

