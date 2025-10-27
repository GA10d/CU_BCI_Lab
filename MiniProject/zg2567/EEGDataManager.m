classdef EEGDataManager
    % Written bt Gustav Guo (zg2567)
    properties
        before_sample;
        after_sample;
        sample_rate;
        %plotManager;
    end

    methods
        function obj = EEGDataManager(before_time, after_time,sample_rate)
            obj.before_sample = ceil(before_time*sample_rate/1000);
            obj.after_sample = ceil(after_time*sample_rate/1000);
            obj.sample_rate = sample_rate;
            %obj.plotManager = PlotManager(before_time, after_time,sample_rate);
        end

        function y = data_capture(obj,trigger,signal)
            y = zeros(length(trigger)-2,obj.after_sample + obj.before_sample + 1);
            for i = 2:length(trigger)-1 % abandon the first and last trigger since it might be incomplete
                y(i-1,:) = signal(trigger(i)-obj.before_sample:trigger(i)+obj.after_sample);
            end
        end

        function y = ERP_calculate(obj,trigger, signal)
           y = zeros(size(signal,1),obj.before_sample + obj.after_sample + 1);
           for i = 1:size(signal,1)
               temp_raw = obj.data_capture(trigger, signal(i,:));
               temp_mean = mean(temp_raw,1);
               y(i,:) = temp_mean;
           end
        end

        function [ERP_non_target,ERP_target,mean_ERP_non_target, mean_ERP_target] = get_mean_ERP(obj,non_target_index, target_index, signal_data)   
            ERP_non_target = obj.ERP_calculate(non_target_index, signal_data);
            ERP_target = obj.ERP_calculate(target_index, signal_data);
            
            mean_ERP_non_target = squeeze(mean(ERP_non_target, 1));
            mean_ERP_target = squeeze(mean(ERP_target, 1));
        end
        function [X_train,Y_train,X_test,Y_test]=get_dataset(obj,train_tuple,test_tuple,use_zscore)
           
            idxtrain_target = train_tuple{1};      
            idxtrain_non_target = train_tuple{2};  
            train_signal = train_tuple{3};         
            
            idxtest_target = test_tuple{1};
            idxtest_non_target = test_tuple{2};
            test_signal = test_tuple{3};
        
            [matrixX_train_target,matrixY_train_target] = obj.get_data_matrix(idxtrain_target,train_signal,1,use_zscore);
            [matrixX_train_flash,matrixY_train_flash] = obj.get_data_matrix(idxtrain_non_target,train_signal,0,use_zscore);
        
            [matrixX_test_target,matrixY_test_target] = obj.get_data_matrix(idxtest_target,test_signal,1,false);
            [matrixX_test_flash,matrixY_test_flash] = obj.get_data_matrix(idxtest_non_target,test_signal,0,false);
        
            X_train = [matrixX_train_target;matrixX_train_flash];
            Y_train = [matrixY_train_target;matrixY_train_flash];
            
            X_test  = [matrixX_test_target;matrixX_test_flash];
            Y_test  = [matrixY_test_target;matrixY_test_flash];
            
        end

        function [matrix_datax, matrix_datay] = get_data_matrix(obj,trigger, signal, label, use_zscore)
        
            if nargin < 4
                use_zscore = false;  
            end
        
            Nch = size(signal, 1);
            Ntrials = size(trigger, 2) - 2;
            Ntime = obj.before_sample + obj.after_sample + 1;
            target_temp = zeros(Nch, Ntrials, Ntime);
        
            for ch = 1:Nch
                target_temp(ch,:,:) = obj.data_capture(trigger, signal(ch,:));
            end
        
            target_temp = permute(target_temp, [2, 1, 3]);  
        
            if use_zscore
                for t = 1:Ntrials
                    for ch = 1:Nch
                        data = squeeze(target_temp(t, ch, :));
                        mu = mean(data);
                        sigma = std(data);
                        if sigma == 0
                            sigma = 1;
                        end
                        target_temp(t, ch, :) = (data - mu) / sigma;
                    end
                end
            end
        
            matrix_datax = reshape(target_temp, Ntrials, Nch * Ntime);
        
            if label == 0
                matrix_datay = zeros(Ntrials, 1);
            else
                matrix_datay = ones(Ntrials, 1);
            end
        end
    end

    methods(Static)
        function data = load_data(data_path)
            data = load(data_path);
        end

        function [time_data,signal_data,trigger_data,target_data]=get_data(data_path)
            eeg_signal = EEGDataManager.load_data(data_path);
            time_data = eeg_signal.y(1:1,:);
            signal_data = eeg_signal.y(2:9,:);
            trigger_data = eeg_signal.y(10:10,:);
            target_data = eeg_signal.y(11:11,:);
        end

        function [m, n] = trigger_alignment(trigger, target)  
            j = 0; m = zeros(1, length(trigger)); %non-target
            k = 0; n = zeros(1, length(trigger)); %target

            for i = 2:length(trigger)
                if target(i) == 1 && target(i-1) == 0
                    k = k + 1;n(k) = i;
                else 
                    if trigger(i) ~= 0 && trigger(i-1) == 0 
                        j = j + 1;m(j) = i;  
                    end
                end
            end
            fprintf("trigger_alignment: find %d target pulse\n", k);
            fprintf("trigger_alignment: find %d non-target pulse\n", j);
            n = n(1:k);  m = m(1:j);
        end

    end

end
