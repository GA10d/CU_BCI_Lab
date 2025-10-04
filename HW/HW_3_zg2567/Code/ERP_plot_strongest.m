function ERP_plot_strongest(data1,data2,data3,data4)
    numChannels = 4;               
    samplingRate = 256;     
    time = (-26:128) / samplingRate;
    figure('Position', [0 0 1200 1200]); 
   
    for i = 1:numChannels
        subplot(2, 2, i);
        switch i
            case 1 
                data = data1;
                name = '500hz stimulation ERP with Attention';
            case 2 
                data = data2;
                name = '900hz stimulation ERP with Attention';
            case 3
                data = data3;
                name = '500hz stimulation ERP without Attention';
            case 4
                data = data4;
                name = '900hz stimulation ERP without Attention';
        end
        plot(time, data, 'LineWidth', 1.2);
        title(['Condition: ', name], 'FontSize', 10);
        xlabel('Time(s)', 'FontSize', 8);
        ylabel('Value(µV)', 'FontSize', 8);
        
        xlim([time(1) time(end)]);
        xticks(0:0.1:max(time));
        xticklabels(xticks);
        set(gca, 'FontSize', 7);
        
        grid on;
        box on;
    end
    
    sgtitle(name); 
saveas(gcf, strcat(name, '.png'));  
saveas(gcf, strcat(name, '.fig'));  
end
