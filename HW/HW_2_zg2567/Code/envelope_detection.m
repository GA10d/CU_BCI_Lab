function [envelope] = envelope_detection(raw_EEG_signal, band_low_cut_off, band_high_cut_off, low_cut_off)
    Fs = 256;
    N_bandpass = 4; 
    N_lowpass = 4;
    signal_length = length(raw_EEG_signal); 
    y_time = (0:signal_length-1) / Fs;

    % bandpass
    [b_band, a_band] = butter(N_bandpass, [band_low_cut_off/(Fs/2), band_high_cut_off/(Fs/2)], 'bandpass');
    
    % filterd signal
    filtered_signal = filtfilt(b_band, a_band, raw_EEG_signal);
    %analytic_signal = hilbert(filtered_signal);

    %raw_envelope = abs(imag(analytic_signal));
    raw_envelope = abs(filtered_signal);
    [b_low, a_low] = butter(N_lowpass, low_cut_off/(Fs/2), 'low');

    envelope = filtfilt(b_low, a_low, raw_envelope);



end
