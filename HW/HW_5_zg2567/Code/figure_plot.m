clear sound;
fs = 44100;        
d = 600;           
fc = 900;         
fm = 30;            
t = (0:1/fs:d-1/fs);

carrier   = sin(2*pi*fc*t); 
modulator = 1 + sin(2*pi*fm*t);   
am_signal = carrier .* modulator;


samples = round(0.1 * fs);
figure;
subplot(3,1,1); plot(t(1:samples)*1000, carrier(1:samples));
title('Carrier (900 Hz)'); xlabel('Time (ms)');
subplot(3,1,2); plot(t(1:samples)*1000, modulator(1:samples));
title(['Modulator ',num2str(fm),'( Hz)']); xlabel('Time (ms)');
subplot(3,1,3); plot(t(1:samples)*1000, am_signal(1:samples));
title(['AM Signal (',num2str(fm),' Hz modulation)']); xlabel('Time (ms)');

exportgraphics(gcf, ['AM Signal (',num2str(fm),' Hz modulation).png'], 'Resolution', 300);



window = hamming(1024);
noverlap = 512;
nfft = 2048;

figure;
spectrogram(am_signal, window, noverlap, nfft, fs, 'yaxis');
xlabel('Time (s)');
ylabel('Frequency (KHz)');
title(['Spectrogram (', num2str(fm), ' Hz AM modulation)']);
colorbar;
exportgraphics(gcf, ['Spectrogram_',num2str(fm),'Hz_modulation.png'], 'Resolution', 300);
