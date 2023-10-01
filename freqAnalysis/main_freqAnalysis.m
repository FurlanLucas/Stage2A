clear; close all;
%% Inputs and definitions
figDir = 'outFig';            % Directory for output figures
analysisName = 'sys1_resFlu'; % Analysis name
expNumber = 1;                % Number for the experiment to be used
orders = [1 4 6 7 9 10];            % Orders for Pade an Taylor approximations
h_comp = [7, 25];             % Values for h (compare)
h = 17;                       % [W/m²K] Final value for h

fprintf("<strong>Frequency analysis</strong>\n");

%% Output directory verification and multidimentional analysis

analysis = analysisSettings(analysisName);

disp("Loading variables.");

load("..\database\convertedData\" + analysisName + ".mat");

%% Main simulations

fprintf("One-dimentional analysis for different h values.\n");
compareh_1d(expData.sysData, analysis, h_comp);

disp("Pade approximation in 1D.");
comparePade_1d(expData.sysData, analysis, h, orders);

disp("Taylor approximation in 1D.");
compareTaylor_1d(expData.sysData, analysis, h, orders);

disp("Comparison between Taylor and Pade.");
comparePadeTaylor(expData.sysData, analysis, h);

disp("Taylor and Pade table.");
prec2table(expData.sysData, analysis, h, orders, 1);
prec2table(expData.sysData, analysis, h, orders, 2);

disp("Multidimentional analysis (comparison).");
compare_1d2d(expData.sysData, analysis, h);

disp("Pade approximation for 2D/3D analysis.");
comparePade_2d(expData.sysData, analysis, h, orders);

disp("Taylor approximation for 2D/3D analysis.");
compareTaylor_2d(expData.sysData, analysis, h, orders);

disp("Writing data to tex files.")
sys2tex(expData, analysis);
writeTransferFunctions(expData, analysis, h, 6)

%% Fin de l'analyse
msg = 'Press any key to continue...';
input(msg);
fprintf(repmat('\b', 1, length(msg)+1)+"\n");
close all;
