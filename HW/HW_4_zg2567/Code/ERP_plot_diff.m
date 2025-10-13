function ERP_plot_diff(data)              
    samplingRate = 256;     
    
    time = (-26:154) / samplingRate;
    
    figure('Position', [0 0 1200 600]); 
    
    plot(time, data, 'LineWidth', 1.2);
    title('Difference of ERP (Target - Non Target)', 'FontSize', 10);
    xlabel('Time(s)', 'FontSize', 8);
    ylabel('Value(µV)', 'FontSize', 8);
    
    xlim([time(1) time(end)]);
    xticks(-1:0.1:max(time));
    xticklabels(xticks);
    set(gca, 'FontSize', 7); 
    
    grid on;
    box on;


saveas(gcf, strcat('Average ERP Diff', '.png'));  
saveas(gcf, strcat('Average ERP Diff', '.fig'));  
end
