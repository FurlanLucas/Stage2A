clc; clear; close all;
%% Entrées
figDir = 'outDir';  % Dossier de sortie pour les figures
prob = 2.5758;      % Propability for 99 %
M = 25;             % Maximum lag value for correlation
sampplot = 500;     % Samplings to plot in time

%% Prendre les données

% With alim.
[t_alim, v_alim, y_b_alim] = text2variable("sys1_alimOnly.txt");

% Ethernet cable
[t_eth, v_eth, y_b_eth] = text2variable("sys1_ethernetOnly.txt");

% Wthout anything
[t_without, v_without, y_b_without] = text2variable("sys1_nothing.txt");


%% Plot dans le temps

% English figure
fig = figure;
subplot(3, 1, 1);
plot(t_alim(1:sampplot)/1e3, y_b_alim(1:sampplot)*1e3, 'r', LineWidth=0.8);
ylabel({"Alim.", "cable"}, Interpreter='latex', ...
    FontSize=17);
grid minor; subplot(3, 1, 2);
plot(t_eth(1:sampplot)/1e3, y_b_eth(1:sampplot)*1e3, 'b', LineWidth=0.8);
ylabel({"Ethernet", "cable"}, Interpreter='latex', ...
    FontSize=17);
grid minor; subplot(3, 1, 3);
plot(t_without(1:sampplot)/1e3, y_b_without(1:sampplot)*1e3, 'g', LineWidth=0.8);
ylabel("Nothing", Interpreter='latex', ...
    FontSize=17);
xlabel("Time (s)", Interpreter='latex', FontSize=17); 
grid minor; fig.Position = [680 321 727 557];
saveas(fig, figDir + "\noiseTime_en.eps", 'epsc');

%% Plot autocorrelation

% Autocorrelations
[R_alim, lag_alim] = xcorr(y_b_alim, M, 'biased');
confRauto_alim = prob/sqrt(length(y_b_alim));

[R_eth, lag_eth] = xcorr(y_b_eth, M, 'biased');
confRauto_eth = prob/sqrt(length(y_b_eth));

[R_without, lag_without] = xcorr(y_b_without, M, 'biased');
confRauto_without = prob/sqrt(length(y_b_without));

% Alim. cable connected plot
fig = figure; 
stem(lag_alim, R_alim/R_alim(M+1), 'b', LineWidth=0.8, MarkerFaceColor='b');
patch([xlim fliplr(xlim)], confRauto_alim*[1 1 -1 -1], 'black', ...
    FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
ylabel({"Amplitude for", "DAS on (mV$^2$)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Time (ms)", Interpreter='latex', FontSize=17); 
grid minor; fig.Position = [680 321 727 557];
saveas(fig, figDir + "\noiseCorrelation_en.eps", 'epsc');

% Ethernet cable connected plot
fig = figure; 
stem(lag_eth, R_eth/R_eth(M+1), 'r', LineWidth=0.8, MarkerFaceColor='r');
patch([xlim fliplr(xlim)], confRauto_eth*[1 1 -1 -1], 'black', ...
    FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
ylabel({"Amplitude for", "DAS on (mV$^2$)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Time (ms)", Interpreter='latex', FontSize=17); 
grid minor; fig.Position = [680 321 727 557];
saveas(fig, figDir + "\noiseCorrelation_en.eps", 'epsc');

% Nothing connected plot
fig = figure; 
stem(lag_without, R_without/R_without(M+1), 'g', LineWidth=0.8, ...
    MarkerFaceColor='g');
patch([xlim fliplr(xlim)], confRauto_without*[1 1 -1 -1], 'black', ...
    FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
ylabel({"Amplitude for", "DAS on (mV$^2$)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Time (ms)", Interpreter='latex', FontSize=17); 
grid minor; fig.Position = [680 321 727 557];
saveas(fig, figDir + "\noiseCorrelation_en.eps", 'epsc');

%% Power plot

% PSD calculation
[power_alim, freq_alim] = signal_psd(y_b_alim, t_alim*1e-3);
[power_eth, freq_eth] = signal_psd(y_b_eth, t_eth*1e-3);
[power_without, freq_without] = signal_psd(y_b_without, t_without*1e-3);

% Autocorrelation en
fig = figure; 
plot(freq_alim, mag2db(power_alim), 'b', LineWidth=0.8, MarkerFaceColor='b');
patch([xlim fliplr(xlim)], confRauto_alim*[1 1 -1 -1], 'black', ...
    FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
ylabel({"Amplitude for", "DAS on (mV$^2$)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Frequence (Hz)", Interpreter='latex', FontSize=17); 
grid minor; fig.Position = [680 321 727 557];
saveas(fig, figDir + "\noiseCorrelation_en.eps", 'epsc');

% Autocorrelation en
fig = figure; 
plot(freq_eth, mag2db(power_eth), 'r', LineWidth=0.8, MarkerFaceColor='b');
patch([xlim fliplr(xlim)], confRauto_eth*[1 1 -1 -1], 'black', ...
    FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
ylabel({"Amplitude for", "DAS on (mV$^2$)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Frequence (Hz)", Interpreter='latex', FontSize=17); 
grid minor; fig.Position = [680 321 727 557];
saveas(fig, figDir + "\noiseCorrelation_en.eps", 'epsc');

% Autocorrelation en
fig = figure; 
plot(freq_without, mag2db(power_without), 'g', LineWidth=0.8, ...
    MarkerFaceColor='b');
patch([xlim fliplr(xlim)], confRauto_without*[1 1 -1 -1], 'black', ...
    FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
ylabel({"Amplitude for", "DAS on (mV$^2$)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Frequence (Hz)", Interpreter='latex', FontSize=17); 
grid minor; fig.Position = [680 321 727 557];
saveas(fig, figDir + "\noiseCorrelation_en.eps", 'epsc');
