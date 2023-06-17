 clc; clear; close all;
%% Entrées et constantes
figDir = 'fig';         % Empacement pour les figures ;
N = 15000;               % [-] Nombre d'échantillons ;
Fmax = 0.5;               % [Hz] Fréquence maximale du signal ;
Fs = 100;                     % [Hz] Fréquence d'echantiollnage ;

%% Signal d'entrée
u = idinput(N, 'prbs', [0, Fmax/Fs]);
t = (0:N-1)/Fs;

% Signal de commande
fig = figure;
plot(t, u, 'r', LineWidth=1.5);
ylabel('Mag (dB)', Interpreter='latex', FontSize=17);
xlabel("Temps (s)", Interpreter='latex', FontSize=17);
grid minor;
saveas(fig, figDir+"\input.png");
title("Entr\'{e}e en pseudo al\'{e}atoire $u(t)$", ...
    Interpreter='latex', FontSize=21);

% DSP
udft = fft(u);
udft = udft(1:N/2+1);
psdu = (1/(Fs*N)) * abs(udft).^2;
psdu(2:end-1) = 2*psdu(2:end-1);
freq = 0:Fs/N:Fs/2;

% DSP figure
fig = figure;
plot(freq, pow2db(psdu))
grid on;
xlabel("Fr\'{e}quence (Hz)", Interpreter='latex', FontSize=17);
ylabel("Puissance/Fr\'{e}quence  (dB/Hz)",Interpreter='latex',FontSize=17);
saveas(fig, figDir+"\dsp.png");
title("Periodogramme en utilisent la FFT",Interpreter='latex',FontSize=21);

%%

u = (rand(fix(N*Fmax/Fs), 1) > 0.5) + 1;
%u = upsample(u - 1, fix(Fs/Fmax));
u = repelem(u-1,fix(Fs/Fmax));
t = (0:length(u)-1)/Fs;

% Signal de commande
fig = figure;
plot(t, u, 'r', LineWidth=1.5);
ylabel('Mag (dB)', Interpreter='latex', FontSize=17);
xlabel("Temps (s)", Interpreter='latex', FontSize=17);
grid minor;
saveas(fig, figDir+"\input2.png");
title("Entr\'{e}e en pseudo al\'{e}atoire $u(t)$", ...
    Interpreter='latex', FontSize=21);

% DSP
udft = fft(u);
udft = udft(1:N/2+1);
psdu = (1/(Fs*N)) * abs(udft).^2;
psdu(2:end-1) = 2*psdu(2:end-1);
freq = 0:Fs/N:Fs/2;

% DSP figure
fig = figure;
plot(freq, pow2db(psdu))
grid on;
xlabel("Fr\'{e}quence (Hz)", Interpreter='latex', FontSize=17);
ylabel("Puissance/Fr\'{e}quence  (dB/Hz)",Interpreter='latex',FontSize=17);
saveas(fig, figDir+"\dsp2.png");
title("Periodogramme en utilisent la FFT",Interpreter='latex',FontSize=21);