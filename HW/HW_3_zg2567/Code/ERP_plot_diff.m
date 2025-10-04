function ERP_plot_diff(data1,data2,data3,data4)              
    samplingRate = 256;     
    time = (-26:128) / samplingRate;

    figure('Position', [100 100 1200 600]); 

    subplot(1, 2, 1);
    plot(time, data2 - data1, 'LineWidth', 1.2, 'Color', 'b');
    title('Attention Stimulation Diff: Divient - Standard', 'FontSize', 10);
    xlabel('Time(s)', 'FontSize', 8);
    ylabel('Value(µV)', 'FontSize', 8);
    
    xlim([time(1) time(end)]);
    xticks(0:0.1:max(time));
    set(gca, 'FontSize', 7);
    grid on;
    box on;
    
    subplot(1, 2, 2);
    plot(time, data4 - data3, 'LineWidth', 1.2, 'Color', 'b');
    title('No Attention Stimulation Diff: Divient - Standard', 'FontSize', 10);
    xlabel('Time(s)', 'FontSize', 8);
    ylabel('Value(µV)', 'FontSize', 8);
    
    xlim([time(1) time(end)]);
    xticks(0:0.1:max(time));
    set(gca, 'FontSize', 7);
    grid on;
    box on;
    hold off;
    
    sgtitle('ERP Diff'); 
    
    saveas(gcf, 'ERP_Diff.png');  
    saveas(gcf, 'ERP_Diff.fig');  
end
