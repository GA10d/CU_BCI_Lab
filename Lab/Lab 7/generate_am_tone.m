clear sound;
fs = 44100;         % 采样频率
d = 600;              % 持续时间 (s)
fc = 900;           % 载波频率 (Hz)
fm = 30;            % 调制频率 (Hz)
t = (0:1/fs:d-1/fs);% 时间向量

carrier   = sin(2*pi*fc*t); 
modulator = 1 + sin(2*pi*fm*t);   
am_signal = carrier .* modulator;


%sound(am_signal, fs);     
%sound(carrier, fs); % 900Hz
%sound(modulator-1,fs);%40Hz


samples = round(0.1 * fs);
figure;
subplot(3,1,1); plot(t(1:samples)*1000, carrier(1:samples));
title('Carrier (900 Hz)'); xlabel('Time (ms)');
subplot(3,1,2); plot(t(1:samples)*1000, modulator(1:samples));
title(['Modulator ',num2str(fm),'( Hz)']); xlabel('Time (ms)');
subplot(3,1,3); plot(t(1:samples)*1000, am_signal(1:samples));
title(['AM Signal (',num2str(fm),' Hz modulation)']); xlabel('Time (ms)');


audiowrite(['am_tone_',num2str(fm),'Hz.wav'], am_signal, fs);

disp(['✅ AM tone (',num2str(fm),' Hz) saved to am_tone_',num2str(fm),'Hz.wav']);
