clc; clear; close all;
%% Entrées et configurations
figDir = 'outFig';                   % Figure output directory
fileDir = 'outCsv';                   % File output directory
inputFileName = 'reentryData1.csv';  % Input file name
outputFileName = 'outFile1.csv';     % Output file name
analysisName = 'sys1_resFlu';        % Analysis name
fs = 10;                              % [s] Sampling frequency

%% Output directory verification and multidimentional analysis

if not(isfolder(figDir))
    mkdir(figDir);
end

if not(isfolder(fileDir))
    mkdir(fileDir);
end

disp("Loading variables.");
addpath('..\dataBase'); % Pour prendre la base de données
load("..\database\convertedData\" + analysisName + ".mat");

%% Flight data

% Take from csv
[phi, t] = takeExpFlux(inputFileName);

% Figure EN
fig = figure;
plot(t/60, phi, 'r', Linewidth=1.5);
grid minor;
xlabel("Time (min)", Interpreter="latex", FontSize=17);
ylabel("Heat flux (W/m$^2$)",Interpreter="latex",FontSize=17);
saveas(fig, figDir + "\dataInterpolated.eps", 'epsc');
title("Input heat flux", Interpreter="latex", FontSize=23);


%% Take the inverse

[tension, t] = createTensionSignal(expData.sysData, phi, t, fs);
toFile(tension, fileDir+"\"+outputFileName);

% Figure
fig = figure;
plot(t/60, tension, 'r', Linewidth=1.5);
grid minor;
xlabel("Time (min)", Interpreter="latex", FontSize=17);
ylabel("Input tension (V)",Interpreter="latex",FontSize=17);
saveas(fig, figDir + "\dataInterpolated.eps", 'epsc');
title("Input generation", Interpreter="latex", FontSize=23);

%% Out
