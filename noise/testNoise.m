clc; clear; close all;
%% Entrées
figDir = 'outDir';  % Dossier de sortie pour les figures ;

%% Prendre les données

% With das
WITH = readtable("with_das.CSV");
t_with = table2array(WITH(:,4));
v_with = table2array(WITH(:,5));

% Without das
WITHOUT = readtable("without_das.CSV");
t_without = table2array(WITHOUT(:,4));
v_without = table2array(WITHOUT(:,5));

%% Plot dans le temps

fig = figure;
subplot(2, 1, 1);
plot(t_without*1e3, v_without, 'r', LineWidth=0.8);
ylabel({"Amplitude pour", "le DAS entandu (mV)"}, Interpreter='latex', ...
    FontSize=17);
grid minor; subplot(2, 1, 2);
plot(t_with*1e3, v_with, 'b', LineWidth=0.8);
ylabel({"Amplitude pour", "le DAS allum\'{e} (mV)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Temps (ms)", Interpreter='latex', FontSize=17); 
fig.Position = [363 123 656 501]; grid minor;
saveas(fig, figDir + "\noiseTime.eps", 'epsc');
sgtitle("Comparaison pour le bruit", Interpreter='latex', FontSize=23); 

%% Plot autocorrelation
[R_with, lag_with] = xcorr(v_with);
[R_without, lag_without] = xcorr(v_without);

fig = figure; 
subplot(2, 1, 1);
plot(lag_without, R_without, 'r', LineWidth=0.8);
ylabel({"Amplitude pour", "le DAS entandu (mV)"}, Interpreter='latex', ...
    FontSize=17);
grid minor; subplot(2, 1, 2);
plot(lag_with, R_with, 'b', LineWidth=0.8);
ylabel({"Amplitude pour", "le DAS allum\'{e} (mV)"}, Interpreter='latex', ...
    FontSize=17);
xlabel("Temps (ms)", Interpreter='latex', FontSize=17); 
fig.Position = [363 123 656 501]; grid minor; 
saveas(fig, figDir + "\noiseTime.eps", 'epsc');
sgtitle("Autocorr\'{e}lation du bruit", Interpreter='latex', FontSize=23);

%% FFT
N = length(v_with); Ts = mean(t_with(2:end)-t_with(1:end-1)); Fe = 1/Ts;
V = abs(fft(v_with.^2));  V = fftshift(V);
f = (0:N-1)*Fe/N;   f = f - f(floor(length(f)/2));

fig = figure;  
plot(f, V, 'r', LineWidth=1.1); 
grid minor;
xlabel("Fr\'equences", Interpreter='latex', FontSize=17); 
ylabel("Amplitude", Interpreter='latex', FontSize=17); 
saveas(fig, figDir + "\noiseTime.eps", 'epsc');
