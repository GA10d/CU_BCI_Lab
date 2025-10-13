function ERP_plot_all(data,name)
    numChannels = 8;               
    samplingRate = 256;     
    
    time = (-26:154) / samplingRate;
    
    figure('Position', [0 0 1200 800],'Name',name); 
    
    for i = 1:numChannels
        subplot(2, 4, i);
        
        plot(time, data(i, :), 'LineWidth', 1.2);
        title(['Channel ', num2str(i)], 'FontSize', 10);
        xlabel('Time(s)', 'FontSize', 8);
        ylabel('Value(µV)', 'FontSize', 8);
        
        xlim([time(1) time(end)]);
        xticks(-1:0.1:max(time));
        xticklabels(xticks);
        set(gca, 'FontSize', 7);
        
        grid on;
        box on;
    end
    
    sgtitle(name); 
saveas(gcf, strcat(name, '.png'));  
saveas(gcf, strcat(name, '.fig'));  
end
