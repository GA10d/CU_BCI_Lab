function model_train_evaluate(tuple, model, name)
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

    figure('Position', [100, 100, 1000, 400]); 
    
    subplot(1, 2, 1);
    confusionchart(Y_test, Y_pred);
    title(['Confusion Matrix (Acc = ', num2str(acc*100, '%.2f'), '%)']);
    
    subplot(1, 2, 2);
    plot(Xroc, Yroc, 'LineWidth', 2);
    xlabel('False Positive Rate');
    ylabel('True Positive Rate');
    title(['ROC Curve (AUC = ', num2str(AUC, '%.3f'), ')']);
    grid on;

    if nargin > 2 && ~isempty(name)
        savefig(['F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Image\Within-Subject Decoding\', name, '_result.fig']);
        print(['F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Image\Within-Subject Decoding\', name, '_result.png'], '-dpng', '-r300');
    end
end
