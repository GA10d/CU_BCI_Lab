clear;clc;
attention_signal = load('F:\Desktop\4090-BCI\HW\HW_3_zg2567\Data\Data_2\RawEEGSignal.mat');
attention_trigger = load('F:\Desktop\4090-BCI\HW\HW_3_zg2567\Data\Data_2\TriggerSignal.mat');
no_attention_signal = load('F:\Desktop\4090-BCI\HW\HW_3_zg2567\Data\Data_3\RawEEGSignal.mat');
no_attention_trigger = load('F:\Desktop\4090-BCI\HW\HW_3_zg2567\Data\Data_3\TriggerSignal.mat');
% triggers
attention_pospulse = trigger_alignment(attention_trigger.trigger_y(2,3000:end),1);
attention_negpulse = trigger_alignment(attention_trigger.trigger_y(2,3000:end),-1);
no_attention_pospulse = trigger_alignment(no_attention_trigger.trigger_y(2,3000:end),1);
no_attention_negpulse = trigger_alignment(no_attention_trigger.trigger_y(2,3000:end),-1);
%signals


attention_y = attention_signal.y(2:17,3000:end);
no_attention_y = no_attention_signal.y(2:17,3000:end);

%ICA

attention_y = remove_artifacts(attention_y);
no_attention_y = remove_artifacts(no_attention_y);


%get ERP
attention_ERP_pos = ERP_calculate(attention_pospulse,attention_y);
attention_ERP_neg = ERP_calculate(attention_negpulse,attention_y);
no_attention_ERP_pos = ERP_calculate(no_attention_pospulse,no_attention_y);
no_attention_ERP_neg = ERP_calculate(no_attention_negpulse,no_attention_y);
%plot every electrodes
ERP_plot_all(attention_ERP_pos,'500hz stimulation ERP with Attention after ICA')
ERP_plot_all(attention_ERP_neg,'900hz stimulation ERP with Attention after ICA')
ERP_plot_all(no_attention_ERP_pos,'500hz stimulation ERP without Attention after ICA')
ERP_plot_all(no_attention_ERP_neg,'900hz stimulation ERP without Attention after ICA')

%plot channel 11
attention_y11 = attention_y(6:6,:);
no_attention_y11 = no_attention_y(6:6,:);
%get ERP
attention_ERP_pos = ERP_calculate(attention_pospulse,attention_y11);
attention_ERP_neg = ERP_calculate(attention_negpulse,attention_y11);
no_attention_ERP_pos = ERP_calculate(no_attention_pospulse,no_attention_y11);
no_attention_ERP_neg = ERP_calculate(no_attention_negpulse,no_attention_y11);
%plot
ERP_plot_strongest(attention_ERP_pos,attention_ERP_neg,no_attention_ERP_pos,no_attention_ERP_neg);
%plot
ERP_plot_comparison(attention_ERP_pos,attention_ERP_neg,no_attention_ERP_pos,no_attention_ERP_neg);
ERP_plot_diff(attention_ERP_pos,attention_ERP_neg,no_attention_ERP_pos,no_attention_ERP_neg);