clear; close all; clc;

Fs = 256;
win = [2.0, 5.5];
band = [8, 20];
filtOrder = 300;

runFiles = { ...
    "Lab1_Run1.mat","Lab1_Run2.mat","Lab1_Run3.mat","Lab1_Run4.mat", ...
    "Lab2_Run1.mat","Lab2_Run2.mat","Lab2_Run3.mat","Lab2_Run4.mat" ...
};

classFiles = { ...
    "classrun1.mat","classrun2.mat","classrun3.mat","classrun4.mat", ...
    "classrun1.mat","classrun2.mat","classrun3.mat","classrun4.mat" ...
};

[left_trials, right_trials, tvec] = load_all_trials(runFiles, classFiles, Fs, win, band, filtOrder);

[Xl, Xr] = cell_to_3d(left_trials, right_trials);

Nleft  = size(Xl,3);
Nright = size(Xr,3);

figure; bar([Nleft, Nright]);
set(gca, 'XTickLabel', {'Left','Right'}); ylabel('Trials');
title('Trial Count');

Rleft  = mean_cov(Xl);
Rright = mean_cov(Xr);

[W, D] = eig(Rleft, Rright);
lam = diag(D);
[lam, ord] = sort(lam, 'ascend');
W = W(:, ord);

sel = [1:3, (size(W,2)-2):size(W,2)];
Wcsp = W(:, sel);
lam_sel = lam(sel);

figure;
for k = 1:6
    subplot(2,3,k);
    topoplot(Wcsp(:,k), 'BCI.locs');
    title(sprintf('CSP %d (\\lambda=%.3g)', k, lam_sel(k)));
end

[Zl, Zr] = project_trials(Xl, Xr, Wcsp);

figure;
for k = 1:6
    subplot(3,2,k); hold on;
    plot(tvec, mean(squeeze(Zl(k,:,:)), 2), 'LineWidth', 1.5);
    plot(tvec, mean(squeeze(Zr(k,:,:)), 2), 'LineWidth', 1.5);
    xlabel('Time (s)'); ylabel('Amplitude');
    title(sprintf('Projected Dim %d', k));
    legend('Left','Right');
    hold off;
end

F_pre  = [features_std_time(Xl); features_std_time(Xr)];
F_post = [features_std_time(Zl); features_std_time(Zr)];

y = [ones(Nleft,1); -ones(Nright,1)];

figure;
subplot(1,2,1);
plot_separability(F_pre, y, 'Before CSP (std over time)');
subplot(1,2,2);
plot_separability(F_post, y, 'After CSP (std over time)');

[accs, acc_mean, acc_se] = lda_10fold_nonoverlap(F_post, y, 10);

fprintf('CSP+LDA 10-fold (non-overlap) Accuracies: %s\n', mat2str(accs,4));
fprintf('Mean Accuracy = %.4f\n', acc_mean);
fprintf('Standard Error = %.4f\n', acc_se);

figure;

b = bar(accs); hold on;
yline(acc_mean, '--k', 'LineWidth', 2);

for i = 1:numel(accs)
    text(i, accs(i) + 0.02, sprintf('%.3f', accs(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 9);
end

text(numel(accs) + 0.3, acc_mean, ...
    sprintf('Mean = %.3f', acc_mean), ...
    'VerticalAlignment', 'middle', ...
    'FontSize', 10, ...
    'FontWeight', 'bold');

xlabel('Fold');
ylabel('Accuracy');
title('CSP + LDA 10-fold Cross-Validation Accuracy');

ylim([0 1]);
xlim([0.5 numel(accs)+1]);
grid on;

legend('Fold Accuracy', 'Mean Accuracy', 'Location', 'northwest');
hold off;

function [left_trials, right_trials, tvec] = load_all_trials(runFiles, classFiles, Fs, win, band, filtOrder)
    left_trials = {};
    right_trials = {};
    nSamp = round((win(2)-win(1))*Fs) + 1;
    tvec = (0:nSamp-1)/Fs + win(1);

    for i = 1:numel(runFiles)
        data = load(runFiles{i});
        classrun = load(classFiles{i});
        [L, R] = get_data_fixed(data, classrun, Fs, win, band, filtOrder);
        left_trials  = [left_trials,  L];
        right_trials = [right_trials, R];
    end
end

function [Xl, Xr] = cell_to_3d(left_trials, right_trials)
    nCh = size(left_trials{1}, 1);
    nS  = size(left_trials{1}, 2);

    Xl = zeros(nCh, nS, numel(left_trials));
    for i = 1:numel(left_trials)
        Xl(:,:,i) = left_trials{i};
    end

    Xr = zeros(nCh, nS, numel(right_trials));
    for i = 1:numel(right_trials)
        Xr(:,:,i) = right_trials{i};
    end
end

function R = mean_cov(X)
    nTr = size(X,3);
    nCh = size(X,1);
    R = zeros(nCh, nCh);
    for i = 1:nTr
        Xi = X(:,:,i);
        Ci = (Xi*Xi') / trace(Xi*Xi');
        R = R + Ci;
    end
    R = R / nTr;
end

function [Zl, Zr] = project_trials(Xl, Xr, Wcsp)
    Zl = zeros(size(Wcsp,2), size(Xl,2), size(Xl,3));
    for i = 1:size(Xl,3)
        Zl(:,:,i) = Wcsp' * Xl(:,:,i);
    end

    Zr = zeros(size(Wcsp,2), size(Xr,2), size(Xr,3));
    for i = 1:size(Xr,3)
        Zr(:,:,i) = Wcsp' * Xr(:,:,i);
    end
end

function F = features_std_time(X)
    nTr = size(X,3);
    nFe = size(X,1);
    F = zeros(nTr, nFe);
    for i = 1:nTr
        F(i,:) = log(std(X(:,:,i), 0, 2) + 1e-12)';
    end
end

function plot_separability(F, y, ttl)
    Fl = F(y==1,:);
    Fr = F(y==-1,:);

    mu_l = mean(Fl,1); mu_r = mean(Fr,1);
    v_l  = var(Fl,0,1); v_r  = var(Fr,0,1);
    fisher = (mu_l - mu_r).^2 ./ (v_l + v_r + 1e-12);

    [~, idx] = sort(fisher, 'descend');
    d1 = idx(1);
    d2 = idx(min(2,numel(idx)));

    scatter(Fl(:,d1), Fl(:,d2), 20, 'filled'); hold on;
    scatter(Fr(:,d1), Fr(:,d2), 20, 'filled');
    xlabel(sprintf('Feat %d', d1)); ylabel(sprintf('Feat %d', d2));
    title(ttl);
    legend('Left','Right');
    grid on; hold off;
end

function [accs, acc_mean, acc_se] = lda_10fold_nonoverlap(F, y, K)
    N = size(F,1);

    idx_pos = find(y==1);
    idx_neg = find(y==-1);

    idx_pos = idx_pos(randperm(numel(idx_pos)));
    idx_neg = idx_neg(randperm(numel(idx_neg)));

    folds = cell(K,1);
    for k = 1:K
        folds{k} = [];
    end

    for i = 1:numel(idx_pos)
        k = mod(i-1, K) + 1;
        folds{k} = [folds{k}; idx_pos(i)];
    end
    for i = 1:numel(idx_neg)
        k = mod(i-1, K) + 1;
        folds{k} = [folds{k}; idx_neg(i)];
    end

    accs = zeros(K,1);
    all_idx = (1:N)';

    for k = 1:K
        test_idx = folds{k};
        train_idx = setdiff(all_idx, test_idx);

        model = lda_train(F(train_idx,:), y(train_idx));
        yhat = lda_predict(model, F(test_idx,:));

        accs(k) = mean(yhat == y(test_idx));
    end

    acc_mean = mean(accs);
    acc_se = std(accs,0) / sqrt(K);
end

function model = lda_train(X, y)
    X1 = X(y==1,:);  X2 = X(y==-1,:);
    m1 = mean(X1,1)'; m2 = mean(X2,1)';

    S1 = cov(X1,1); S2 = cov(X2,1);
    Sw = S1 + S2 + 1e-6*eye(size(X,2));

    w = Sw \ (m1 - m2);
    b = -0.5 * (m1 + m2)' * w;

    model.w = w;
    model.b = b;
end

function yhat = lda_predict(model, X)
    scores = X * model.w + model.b;
    yhat = ones(size(scores));
    yhat(scores < 0) = -1;
end

function [segments_left, segments_right] = get_data_fixed(data, classrun, Fs, win, band, filtOrder)
    [idx_left, idx_right] = get_idx(data, classrun);

    [t_start_l, t_end_l] = align_data(data, idx_left,  win(1), win(2));
    [t_start_r, t_end_r] = align_data(data, idx_right, win(1), win(2));

    segments_left  = segment_data_fixed(data, t_start_l, t_end_l, Fs, band, filtOrder);
    segments_right = segment_data_fixed(data, t_start_r, t_end_r, Fs, band, filtOrder);
end

function [t_start, t_end] = align_data(data, idx, ts, te)
    time = data.y(1,:);
    t_idx = time(idx);
    t_start = t_idx + ts;
    t_end   = t_idx + te;
end

function [left, right] = get_idx(data, classrun)
    trigger = data.y(18,:);
    idx = find(trigger(1:end-1) == 1 & trigger(2:end) == 0);

    fn = fieldnames(classrun);
    labels = classrun.(fn{1});

    n = min(size(labels,2), numel(idx));
    idx = idx(1:n);
    labels = labels(:,1:n);

    left  = idx(labels(1,:) == 1);
    right = idx(labels(2,:) == 1);
end

function segments = segment_data_fixed(data, t_start, t_end, Fs, band, filtOrder)
    time = data.y(1,:);
    signal = data.y(2:17,:);

    bpFilt = designfilt('bandpassfir', ...
        'FilterOrder', filtOrder, ...
        'CutoffFrequency1', band(1), ...
        'CutoffFrequency2', band(2), ...
        'SampleRate', Fs);

    sigf = filtfilt(bpFilt, double(signal') )';

    nSeg = numel(t_start);
    nSamp = round((t_end(1)-t_start(1))*Fs) + 1;

    segments = cell(1, nSeg);
    for i = 1:nSeg
        s0 = find(time >= t_start(i), 1, 'first');
        if isempty(s0), continue; end
        if (s0 + nSamp - 1) > numel(time), continue; end
        idx = s0 : (s0 + nSamp - 1);
        segments{i} = sigf(:, idx);
    end
    segments = segments(~cellfun(@isempty, segments));
end
