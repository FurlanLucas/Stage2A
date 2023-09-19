clc; clear; close all;
%% Entrées
figDir = 'outDir';  % Dossier de sortie pour les figures ;
prob = 5.5758;      % Propability for 99 %
M = 30;

%% Prendre les données

% With das
WITH = readtable("sys2_isoRes_0002.csv");
t_with = table2array(WITH(:,1));
v_with = table2array(WITH(:,2));

% Without das
WITHOUT = readtable("sys2_isoRes_0001.csv");
t_without = table2array(WITHOUT(:,1));
v_without = table2array(WITHOUT(:,2));

%% Plot dans le temps

% English figure
fig = figure;
subplot(2, 1, 1);
plot(t_without*1e3, v_without, 'r', LineWidth=0.8);
ylabel({"Amplitude for", "DAS off (mV)"}, Interpreter='latex', ...
    FontSize=17);
grid minor; subplot(2, 1, 2);
plot(t_with*1e3, v_with, 'b', LineWidth=0.8);
ylabel({"Amplitude for", "DAS on (mV)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Time (ms)", Interpreter='latex', FontSize=17); 
grid minor; fig.Position = [680 321 727 557];
saveas(fig, figDir + "\noiseTime_en.eps", 'epsc');

% French figure
ylabel({"Amplitude pour", "le DAS allum\'{e} (mV)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Temps (ms)", Interpreter='latex', FontSize=17); 
subplot(2, 1, 1);
ylabel({"Amplitude pour", "le DAS entandu (mV)"}, Interpreter='latex', ...
    FontSize=17);
saveas(fig, figDir + "\noiseTime_fr.eps", 'epsc');
sgtitle("Comparaison pour le bruit", Interpreter='latex', FontSize=23); 
 
%% Plot autocorrelation
[R_with, lag_with] = xcorr(v_with, M, 'biased');
confRauto_with = prob/sqrt(length(v_with));
[R_without, lag_without] = xcorr(v_without, M, 'biased');
confRauto_without = prob/sqrt(length(v_without));

% Autocorrelation en
fig = figure; 
subplot(2, 1, 1);
stem(lag_without, R_without/R_without(M+1), 'r', LineWidth=0.8, ...
    MarkerFaceColor='r');
patch([xlim fliplr(xlim)], confRauto_without*[1 1 -1 -1], 'black', ...
    FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
ylabel({"Amplitude for", "DAS off (mV$^2$)"}, Interpreter='latex', ...
    FontSize=17);
grid minor; subplot(2, 1, 2);
stem(lag_with, R_with/R_with(M+1), 'b', LineWidth=0.8, MarkerFaceColor='b');
patch([xlim fliplr(xlim)], confRauto_with*[1 1 -1 -1], 'black', ...
    FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
ylabel({"Amplitude for", "DAS on (mV$^2$)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Time (ms)", Interpreter='latex', FontSize=17); 
grid minor; fig.Position = [680 321 727 557];
saveas(fig, figDir + "\noiseCorrelation_en.eps", 'epsc');

% Autocorrelation en
subplot(2, 1, 1);
ylabel({"Amplitude pour", "le DAS entandu (mV$^2$)"}, Interpreter='latex', ...
    FontSize=17);
grid minor; subplot(2, 1, 2);
ylabel({"Amplitude pour", "le DAS allum\'{e} (mV$^2$)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Temps (ms)", Interpreter='latex', FontSize=17); 
saveas(fig, figDir + "\noiseCorrelation_fr.eps", 'epsc');
sgtitle("Autocorr\'{e}lation du bruit", Interpreter='latex', FontSize=23);



%% FFT
[power, freq] = signal_psd(v_with, t_with);

fig = figure;  
plot(freq, power, 'r', LineWidth=1.1); 
grid minor;
xlabel("Fr\'equences (Hz)", Interpreter='latex', FontSize=17); 
ylabel("Amplitude (dB/Hz)", Interpreter='latex', FontSize=17); 
saveas(fig, figDir + "\FFT_noise.eps", 'epsc');
