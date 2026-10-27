function cleaned_data = remove_artifacts(raw_data)
    % raw_data: 16×n EEG 信号矩阵（通道 × 时间点）
    % cleaned_data: 去伪迹后的信号矩阵
    
    % ICA 分解
    [weights, sphere] = runica(raw_data);
    ica_components = weights * sphere * raw_data;

    % -------------------------------
    % 自动判定伪迹成分
    % 方法：统计每个成分的振幅异常情况
    % -------------------------------
    comp_std = std(ica_components, 0, 2); % 各成分的标准差
    z_scores = (comp_std - mean(comp_std)) / std(comp_std);

    % 振幅显著异常的成分认为是伪迹
    threshold_z = 2; % z-score阈值，可调节
    artifact_idx = find(z_scores > threshold_z);

    fprintf('自动检测到 %d 个可能的伪迹成分：', length(artifact_idx));
    disp(artifact_idx');

    % 去除伪迹成分
    ica_components(artifact_idx, :) = 0;

    % 重构信号
    cleaned_data = pinv(weights * sphere) * ica_components;
end
