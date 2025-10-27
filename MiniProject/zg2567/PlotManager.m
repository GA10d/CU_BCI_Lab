classdef PlotManager
    % Written bt Gustav Guo (zg2567)
    properties
        before_time;
        after_time;
        before_sample;
        after_sample;
        sample_rate;
        plot_flag;
        save_flag;
    end

    methods
        function obj = PlotManager(bt,at,sr,pf,sf)
            obj.before_time = bt;
            obj.after_time = at;
            obj.before_sample = ceil(bt*sr/1000);
            obj.after_sample = ceil(at*sr/1000);
            obj.sample_rate = sr;
            obj.plot_flag = pf;
            obj.save_flag = sf;
        end
        
        function save_image(obj,path,name)
            if obj.save_flag
                savefig([path, name, '.fig']);
                print([path, name, '.png'], '-dpng', '-r300');
            end
        end

        function plot_beta_topoplt(obj,data8, locFile, name)
            if obj.plot_flag
                data16 = nan(16, size(data8,2));  
                data16(1,:)   = data8(1,:);  % Fz
                data16(6,:)   = data8(2,:);  % Cz
                data16(11,:)  = data8(4,:);  % Pz
                data16(12,:)  = data8(5,:);  % P4
                data16(13,:)  = data8(3,:);  % P3
                data16(14,:)  = data8(8,:);  % PO8
                data16(15,:)  = data8(6,:);  % PO7
                data16(16,:)  = data8(7,:);  % Oz
            
            
                vals = data16(:, :);
                clim = [min(vals(:)), max(vals(:))];
            
                figure;
                topoplot(data16(:, :), locFile, ...
                         'maplimits', clim, ... 
                         'electrodes', 'labels', ...
                         'style', 'both');
                title(['Beta']);
                
                h = colorbar('eastoutside');
                h.Label.String = 'Amplitude (\muV)';
                     
                obj.save_image(Constants.squard_beta,name);
            end
        end
        
        function plot_corr(obj,time_corr,corr_vals,best_time,max_corr,name)
            if obj.plot_flag
                figure;
                plot(time_corr, corr_vals, 'LineWidth', 1.5);
                xlabel('Time (ms)');
                ylabel('Sliding correlation');
                title('Sliding correlation between Power of Weights and Mean ERP');
                grid on;
                xline(best_time, '--r', sprintf('Max corr = %.2f at %.1f ms', max_corr, best_time));
                obj.save_image(Constants.squard_beta, name);
            end
        end

        function plot_beta_line(obj, powerofweights, mean_ERP_target, name)
            if obj.plot_flag
                figure;
        
                time = linspace(-obj.before_time, obj.after_time, length(powerofweights));
        
                yyaxis left
                plot(time, powerofweights, 'b', 'LineWidth', 1.5);
                ylabel('Power of weights');
                ylim([min(powerofweights), 1.2 * max(powerofweights)]);
        
                yyaxis right
                plot(time, mean_ERP_target, 'r', 'LineWidth', 1.5);
                ylabel('Mean ERP Target');
                ylim([min(mean_ERP_target), 1.1*max(mean_ERP_target)]);
        
                title('Comparison of Power of Weights and Mean ERP');
                xlabel('Time (ms)');
                legend({'Power of Weights', 'Mean ERP Target'}, 'Location', 'best');
                grid on;
        
        
                obj.save_image(Constants.squard_beta, name);
            end
        end


        function plot_scalp_maps(obj,data8, locFile, name)
            if obj.plot_flag
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
                fs = obj.sample_rate;  
                sample_list = round(time_list / 1000 * fs);  
            
                vals = data16(:, sample_list);
                clim = [min(vals(:)), max(vals(:))];
            
                figure;
                for i = 1:length(sample_list)
                    ax = subplot(2, 2, i);  
                    topoplot(data16(:, sample_list(i)), locFile, ...
                             'maplimits', clim, ... 
                             'electrodes', 'labels', ...
                             'style', 'both');
                    title([num2str(time_list(i)-100) ' ms']);
                    
                    h = colorbar(ax, 'eastoutside');
                    h.Label.String = 'Amplitude (\muV)';
                     
                end
                obj.save_image(Constants.topoplot_image_path,name);
            end
        end

        function plot_mean_ERP(obj,mean_ERP_non_target,mean_ERP_target,name)
            if obj.plot_flag
                num_time_points = length(mean_ERP_non_target);
                time_interval = 1000 / obj.sample_rate;
                time_ms = -obj.before_time : time_interval : (-obj.before_time + (num_time_points-1)*time_interval);
                
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

                obj.save_image(Constants.erp_image_path,name);
            end
        end
        
        function plot_model_evaluation(obj, result)
            if obj.plot_flag
                figure('Position', [100, 100, 1000, 400]); 
                
                subplot(1, 2, 1);
                confusionchart(result.Y_test, result.Y_pred);
                title(['Confusion Matrix (Acc = ', num2str(result.acc*100, '%.2f'), '%)']);
                
                subplot(1, 2, 2);
                plot(result.Xroc, result.Yroc, 'LineWidth', 2);
                xlabel('False Positive Rate');
                ylabel('True Positive Rate');
                title(['ROC Curve (AUC = ', num2str(result.AUC, '%.3f'), ')']);
                grid on;
        
                obj.save_image(Constants.within_subject_image_path, 'train1_test1');
            end
        end

        function plot_all_model_results(obj, results, combinations)
            if ~obj.plot_flag
                return;
            end
        
            numCombinations = numel(combinations);
            rows = 3; cols = 3; 
        
            figure('Position', [100, 100, 1200, 900]);
            for i = 1:numCombinations
                result = results{i};
                c = combinations{i};
                name = [c{1}, ' & ', c{4}];
                subplot(rows, cols, i);
                confusionchart(result.Y_test, result.Y_pred);
                title({['Confusion: ', name], ...
                       ['Acc = ', num2str(result.acc*100, '%.1f'), '%']});
            end
            sgtitle('Confusion Matrices of All Models');
            obj.save_image(Constants.within_subject_image_path, 'All_Confusion_Matrices');
        
            figure('Position', [100, 100, 1200, 900]);
            for i = 1:numCombinations
                result = results{i};
                c = combinations{i};
                name = [c{1}, ' & ', c{4}];
                subplot(rows, cols, i);
                plot(result.Xroc, result.Yroc, 'LineWidth', 1.5);
                xlabel('False Positive Rate');
                ylabel('True Positive Rate');
                title({['ROC: ', name], ...
                       ['AUC = ', num2str(result.AUC, '%.3f')]});
                grid on;
            end
            sgtitle('ROC Curves of All Models');
            obj.save_image(Constants.within_subject_image_path, 'All_ROC_Curves');
        end


end
end


