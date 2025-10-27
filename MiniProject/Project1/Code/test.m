
before_sample = 26; % 0.1s * 256 (sample rate)
after_sample = 154; % 0.6s * 256 (sample rate)

non_target = idxtrain2_non_target;
trigger = idxtrain2_target;

matrix_data = zeros(size(trigger,2)-2,(before_sample+after_sample+1)*8);


target_temp = zeros(8,size(trigger,2)-2,before_sample+after_sample+1);

for i = 1:size(signal,1)
   target_temp(i,:,:) = data_capture(trigger, signal(i,:), before_sample, after_sample);
end
target_temp = permute(target_temp, [2, 3, 1]);

Ntrials = size(target_temp,1);
Nch = size(target_temp,2);
Ntime = size(target_temp,3);

matrix_data = reshape(target_temp, Ntrials, Nch*Ntime);

