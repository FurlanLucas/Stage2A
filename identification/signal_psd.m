function [power, freq] = signal_psd(signal, time)
    %% psd
    %
    % Power spectral density.

    %% Inputs
    
    Ts = time(2) - time(1);     % [s] Sampling period
    fs = 1/Ts;                  % [Hz] Sampling frequency
    N = length(signal);         % Signal length

    %% Main

    % Input correction
    if mod(N, 2)
        signal = signal(1:end-1);
        N = N - 1;
    end
    
    signaldft = fft(signal);
    signaldft = signaldft(1:N/2+1);
    power = (1/(fs*N)) * abs(signaldft).^2;
    power(2:end-1) = 2*power(2:end-1);
    freq = 0:fs/length(signal):fs/2;

end