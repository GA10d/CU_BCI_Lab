classdef WithinSubjectModelManager
    % Written bt Gustav Guo (zg2567)
    properties
    end

    methods(Static)
        function [result,Mdl] = model_train_evaluate(tuple, model, name)
            X_train = tuple{1};
            Y_train = tuple{2};
            X_test  = tuple{3};
            Y_test  = tuple{4};
            
            Mdl = fitclinear(X_train, Y_train, ...
                'Learner', model, ...
                'Regularization', 'lasso', ...
                'Solver', 'sparsa', ...
                'ObservationsIn', 'rows');
            
            [Y_pred, score] = predict(Mdl, X_test);
            
            acc = mean(Y_pred == Y_test);
            fprintf([name, ' result\n']);
            fprintf('Test accuracy = %.2f%%\n', acc*100);
        
            cm = confusionmat(Y_test, Y_pred);
            precision = cm(2,2) / sum(cm(:,2));
            recall    = cm(2,2) / sum(cm(2,:));
            F1 = 2 * precision * recall / (precision + recall);
            fprintf('Precision = %.2f, Recall = %.2f, F1 = %.2f\n', ...
                precision, recall, F1);
        
            [Xroc, Yroc, ~, AUC] = perfcurve(Y_test, score(:,2), 1);
            result = struct( ...
            'Y_test', Y_test, ...
            'Y_pred', Y_pred, ...
            'Xroc', Xroc, ...
            'Yroc', Yroc, ...
            'AUC', AUC, ...
            'acc', acc);
        
        end
        function [max_corr, best_time, corr_vals, time_corr] = find_best_correlation(x, y, time, window_size)
            if length(x) ~= length(y) || length(x) ~= length(time)
                error('x, y, and time must have the same length.');
            end
        
            n = length(x);
            corr_vals = zeros(1, n - window_size + 1);
            for i = 1:(n - window_size + 1)
                x_win = x(i:i+window_size-1);
                y_win = y(i:i+window_size-1);
                r = corrcoef(x_win, y_win);
                corr_vals(i) = r(1,2);
            end
        
            [max_corr, idx] = max(corr_vals);
            best_time = time(idx + floor(window_size/2));
            time_corr = time(1:end - window_size + 1) + ...
                        (window_size/2)*(time(2) - time(1));
        end

        end
end
