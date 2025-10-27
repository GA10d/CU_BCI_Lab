function [matrix_datax, matrix_datay] = get_data_matrix(trigger, signal, label, use_zscore)

    if nargin < 4
        use_zscore = false;  
    end

    before_sample = 26;  % 0.1s * 256 Hz
    after_sample  = 154; % 0.6s * 256 Hz
    Nch = size(signal, 1);

    Ntrials = size(trigger, 2) - 2;
    Ntime = before_sample + after_sample + 1;
    target_temp = zeros(Nch, Ntrials, Ntime);

    for ch = 1:Nch
        target_temp(ch,:,:) = data_capture(trigger, signal(ch,:), before_sample, after_sample);
    end

    target_temp = permute(target_temp, [2, 1, 3]);  

    if use_zscore
        for t = 1:Ntrials
            for ch = 1:Nch
                data = squeeze(target_temp(t, ch, :));
                mu = mean(data);
                sigma = std(data);
                if sigma == 0
                    sigma = 1;
                end
                target_temp(t, ch, :) = (data - mu) / sigma;
            end
        end
    end

    matrix_datax = reshape(target_temp, Ntrials, Nch * Ntime);

    if label == 0
        matrix_datay = zeros(Ntrials, 1);
    else
        matrix_datay = ones(Ntrials, 1);
    end
end
