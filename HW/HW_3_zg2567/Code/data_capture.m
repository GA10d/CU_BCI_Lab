function y = data_capture(trigger,signal, before_sample, after_sample)
    y = zeros(length(trigger)-2,after_sample+before_sample+1);
    for i = 2:length(trigger)-1 % abandon the first and last trigger since it might be incomplete
        y(i-1,:) = signal(trigger(i)-before_sample:trigger(i)+after_sample);
    end

end
