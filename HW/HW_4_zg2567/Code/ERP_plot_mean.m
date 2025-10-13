function ERP_plot_mean(data1,data2)              
    samplingRate = 256;     
    
    time = (-26:154) / samplingRate;
    
    figure('Position', [0 0 1200 600]); 
    
    subplot(1, 2, 1);
    
    plot(time, data1, 'LineWidth', 1.2);
    title('Target Characters ERP', 'FontSize', 10);
    xlabel('Time(s)', 'FontSize', 8);
    ylabel('Value(µV)', 'FontSize', 8);
    
    xlim([time(1) time(end)]);
    xticks(-1:0.1:max(time));
    xticklabels(xticks);
    set(gca, 'FontSize', 7);

    ylim([-2 3]);    
    
    grid on;
    box on;
    
    subplot(1, 2, 2);
    
    plot(time, data2, 'LineWidth', 1.2);
    title('Non-target Characters ERP', 'FontSize', 10);
    xlabel('Time(s)', 'FontSize', 8);
    ylabel('Value(µV)', 'FontSize', 8);
    
    xlim([time(1) time(end)]);
    xticks(-1:0.1:max(time));
    xticklabels(xticks);
    set(gca, 'FontSize', 7);
    ylim([-2 3]);  
    grid on;
    box on;
    


saveas(gcf, strcat('Average ERP', '.png'));  
saveas(gcf, strcat('Average ERP', '.fig'));  
end
