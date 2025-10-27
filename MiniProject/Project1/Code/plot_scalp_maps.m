function plot_scalp_maps(data8, locFile, name)
    % 将8通道数据扩展到16通道
    data16 = nan(16, size(data8,2));  
    data16(1,:)   = data8(1,:);  % Fz
    data16(6,:)   = data8(2,:);  % Cz
    data16(11,:)  = data8(4,:);  % Pz
    data16(12,:)  = data8(5,:);  % P4
    data16(13,:)  = data8(3,:);  % P3
    data16(14,:)  = data8(8,:);  % PO8
    data16(15,:)  = data8(6,:);  % PO7
    data16(16,:)  = data8(7,:);  % Oz

    time_list = [100, 200, 300, 400];  
    fs = 256;  
    sample_list = round(time_list / 1000 * fs);  

    % 找出选定时间点的最大最小值，用于统一 colorbar
    vals = data16(:, sample_list);
    clim = [min(vals(:)), max(vals(:))];

    figure;
    for i = 1:length(sample_list)
        ax = subplot(2, 2, i);  
        topoplot(data16(:, sample_list(i)), locFile, ...
                 'maplimits', clim, ...  % 统一色阶
                 'electrodes', 'labels', ...
                 'style', 'both');
        title([num2str(time_list(i)) ' ms']);
        
        % 为每个子图右侧添加 colorbar
        h = colorbar(ax, 'eastoutside');
        h.Label.String = 'Amplitude (\muV)';
        caxis(ax, clim);  % 确保 colorbar 与子图一致
    end

    % 保存
    savefig(['F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Image\Topoplot\', name, '.fig']);
    print(['F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Image\Topoplot\', name, '.png'], '-dpng', '-r300');
end
