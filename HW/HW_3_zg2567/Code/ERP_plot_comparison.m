function ERP_plot_comparison(data1,data2,data3,data4)              
    samplingRate = 256;     
    time = (-26:128) / samplingRate;

    figure('Position', [100 100 1200 600]); 

    subplot(1, 2, 1);
    plot(time, data1, 'LineWidth', 1.2, 'Color', 'b');
    hold on;  
    plot(time, data2, 'LineWidth', 1.2, 'Color', 'r', 'LineStyle', '--');
    title('Attention Stimulation: Standard vs Divient', 'FontSize', 10);
    xlabel('Time(s)', 'FontSize', 8);
    ylabel('Value(µV)', 'FontSize', 8);
    legend({'Standard', 'Divient'}, 'FontSize', 7);  
    
    xlim([time(1) time(end)]);
    xticks(0:0.1:max(time));
    set(gca, 'FontSize', 7);
    grid on;
    box on;
    hold off;  
    
    subplot(1, 2, 2);
    plot(time, data3, 'LineWidth', 1.2, 'Color', 'b');
    hold on;
    plot(time, data4, 'LineWidth', 1.2, 'Color', 'r', 'LineStyle', '--');
    title('No Attention Stimulation: Standard vs Divient', 'FontSize', 10);
    xlabel('Time(s)', 'FontSize', 8);
    ylabel('Value(µV)', 'FontSize', 8);
    legend({'Standard', 'Divient'}, 'FontSize', 7);
    
    xlim([time(1) time(end)]);
    xticks(0:0.1:max(time));
    set(gca, 'FontSize', 7);
    grid on;
    box on;
    hold off;
    
    sgtitle('ERP Comparison: Stimulation under Different Stimulation Conditions'); 
    
    saveas(gcf, 'ERP_comparison.png');  
    saveas(gcf, 'ERP_comparison.fig');  
end
