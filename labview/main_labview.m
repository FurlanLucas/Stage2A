%clear; close all;
%% Inputs and definitions
figDir = 'outFig';            % Directory for output figures
analysisName = 'sys1_resFlu'; % Analysis name
analysisNumber = 2;           % Number for the experiment to be used
delayOrders = [0 20 10];      % Delay orders value
Tmin = 10;                    % [s] Minimum period present in the signal

fprintf("<strong>Labview PRBS</strong>\n");

%% Output directory verification and multidimentional analysis
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

% Take the data
disp("Loading variables.");
addpath('..\myClasses'); % For the class definitions
addpath('..\dataBase'); % For the database
load("..\database\convertedData\" + analysisName + ".mat");

%% Signal variables
u = expData.v{analysisNumber};
t = expData.t{analysisNumber}/1e3;
N = length(u);

%% Main

% FFT (expData)
[power, freq] = signal_psd(u, t);

% Theorical analysis 
a = max(u);
power_th = (a/2)^2*(N+1)*(2*Tmin/N)*(sinc(freq*Tmin).^2);  

% Matlab version
warning off;
u = idinput(N, 'prbs', [0, 0.1/Tmin], [0, a]);
warning on;
[power_matlab, freq] = signal_psd(u, t);

% Figure (english)
fig = figure; hold on;
h1 = plot(freq, pow2db(power), 'r', LineWidth=1.2, ...
    DisplayName='Labview generated');
h2 = plot(freq, pow2db(power_matlab), 'b', LineWidth=1.2, ...
    DisplayName='Matlab generated');
h3 = plot(freq, pow2db(power_th), 'k', LineWidth=1.2, ...
    DisplayName='Theoretical');
xlabel("Frequency (Hz)", Interpreter="latex", FontSize=17);
ylabel("Power Spectral (dB/Hz)", Interpreter="latex", FontSize=17);
legend(Location="northeast", Interpreter="latex", FontSize=17);
grid minor; xlim([0, 4*(1/Tmin)]); ylim([-10 60]);
saveas(fig, figDir + "\" + analysisName + "\" + "PRBS_power_en.eps", ...
    'epsc');

% Figure (french)
xlabel("Fr\'{e}quence (Hz)", Interpreter="latex", FontSize=17);
ylabel("DSP (dB/Hz)", Interpreter="latex", FontSize=17);
set(h1, 'DisplayName', "G\'{e}n\'{e}r\'{e} par Labview");
set(h2, 'DisplayName', "G\'{e}n\'{e}r\'{e} par Matlab");
set(h3, 'DisplayName', "Th\'{e}orique");
saveas(fig, figDir + "\" + analysisName + "\" + "PRBS_power_fr.eps", ...
    'epsc');
