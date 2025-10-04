function y = ERP_calculate(trigger, signal)
    %signal ==> 16*n
   before_sample = 26; % 0.1s * 256 (sample rate)
   after_sample = 128; % 0.5s * 256 (sample rate)

   y = zeros(size(signal,1),before_sample+after_sample+1);

   for i = 1:size(signal,1)
       temp_raw = data_capture(trigger, signal(i,:), before_sample, after_sample);
       temp_mean = mean(temp_raw,1);
       y(i,:) = temp_mean;
   end
end
