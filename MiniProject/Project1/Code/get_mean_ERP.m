function [ERP_non_target,ERP_target,mean_ERP_non_target, mean_ERP_target] = get_mean_ERP(non_target_index, target_index, signal_data, plot_flag, name)   
    ERP_non_target = ERP_calculate(non_target_index, signal_data);
    ERP_target = ERP_calculate(target_index, signal_data);
    
    mean_ERP_non_target = squeeze(mean(ERP_non_target, 1));
    mean_ERP_target = squeeze(mean(ERP_target, 1));
    
    if plot_flag
        num_time_points = length(mean_ERP_non_target);
        time_interval = 1000 / 256;
        time_ms = -100 : time_interval : (-100 + (num_time_points-1)*time_interval);
        
        figure;
        hold on; grid on;
        
        plot(time_ms, mean_ERP_non_target, 'b-', 'LineWidth', 1.2);
        plot(time_ms, mean_ERP_target, 'r-', 'LineWidth', 1.2);
        
        plot([0, 0], ylim, 'k--', 'LineWidth', 1);
        text(5, min(ylim)*0.9, 'Stimulus Onset', 'Color', 'k', 'FontSize', 9);
        
        y_range = ylim;
        rect_pos = [300, y_range(1), 200, y_range(2)-y_range(1)];
        rectangle('Position', rect_pos, ...
                  'FaceColor', [1, 0.7, 0.8], ...
                  'EdgeColor', 'k', ...
                  'LineWidth', 1, ...
                  'FaceAlpha', 0.3);
        
        text(400, y_range(2)*0.95, 'P300', 'Color', 'k', 'FontSize', 10, ...
             'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        
        xlabel('Time (ms)', 'FontSize', 10);
        ylabel('Amplitude (μV)', 'FontSize', 10);
        title('Average ERP: Target vs Non-Target', 'FontSize', 12);
        legend('Non-Target ERP', 'Target ERP', 'Stimulus Onset', 'Location', 'best');
        xlim([-100, 600]);
        ylim(y_range);
        
        hold off;
        savefig(['F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Image\ERP', name, '.fig']);
        print(['F:\Documents\GitHub\CU_BCI_Lab\MiniProject\Project1\Image\ERP', name, '.png'], '-dpng', '-r300');
    end
end