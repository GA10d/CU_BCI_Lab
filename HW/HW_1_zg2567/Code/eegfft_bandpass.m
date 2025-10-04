function [x_filtered, f, X, X_filtered] = eegfft_bandpass(x, Fs, f_low, f_high)
    N = length(x);  % 信号长度
    
    % 计算FFT
    X = fft(x);
    
    % 生成频率轴（以0为中心）
    f = (0:N-1) * (Fs / N);  % 原始频率轴（0到Fs）
    f = f - Fs/2;  % 转换为以0为中心（-Fs/2到Fs/2）
    
    % 设计带通滤波器掩码
    mask = (abs(f) >= f_low) & (abs(f) <= f_high);  % 保留目标频段
    
    % 应用滤波（频域置零）
    X_filtered = X .* mask;
    
    % 逆FFT得到滤波后信号（取实部消除数值误差）
    x_filtered = real(ifft(X_filtered));
end
