data = load('task2.mat');
time = data.y(1,:);
signal = data.y(2,:);

idx_20Hz = (time >= 10 & time <= 50);
idx_30Hz = (time >= 70 & time <= 110);

signal20Hz = signal(idx_20Hz);
signal30Hz = signal(idx_30Hz);

mean20 = mean(signal20Hz);
mean30 = mean(signal30Hz);

figure;
hold on;

plot(signal20Hz, 'b', 'LineWidth', 1.2);
plot(signal30Hz, 'r', 'LineWidth', 1.2);
yline(mean20, '--b', 'LineWidth', 1.5);
yline(mean30, '--r', 'LineWidth', 1.5);

title('Signal Segments with Mean Values');
xlabel('Index');
ylabel('Amplitude');
legend('20 Hz segment','30 Hz segment','20 Hz mean','30 Hz mean');
grid on;
hold off;
