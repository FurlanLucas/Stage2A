clear; close all;
%% Inputs and definitions
figDir = 'outFig';            % Directory for output figures
analysisName = 'sys1_resFlu'; % Analysis name
expNumber = 1;                % Number for the experiment to be used
orders = [1 6 10];            % Orders for Pade an Taylor approximations
h_comp = [7, 25];             % Values for h (compare)
h = 17;                       % [W/m²K] Final value for h
Ts = 100e-3;                  % [s] Time sampling (discretization of tf)

fprintf("<strong>Frequency analysis</strong>\n");

%% Output directory verification and multidimentional analysis
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

disp("Loading variables.");
addpath('..\database', '..\myClasses');
load("..\database\convertedData\" + analysisName + ".mat");

%% Main simulations

analysis = analysisSettings();

fprintf("One-dimentional analysis for different h values.\n");
compareh_1d(expData.sysData, analysis, h_comp);

disp("Pade approximation in 1D.");
comparePade_1d(expData.sysData, analysis, h, orders);

disp("Pade approximation in 1D.");
compareTaylor_1d(expData.sysData, analysis, h, orders);

disp("Comparison between Taylor and Pade.");
comparePadeTaylor(expData.sysData, analysis, h);

disp("Multidimentional analysis (comparison).");
compare_1d2d(expData.sysData, analysis, h);

disp("Pade approximation for 2D/3D analysis.");
comparePade_2d(expData.sysData, analysis, h, orders);

disp("Taylor approximation for 2D/3D analysis.");
compareTaylor_2d(expData.sysData, analysis, h, orders);

%% Write some data to tables (latex)

sys2tex(expData);

% Taylor 1D
[~, Fs_taylor_1d] = model_1d_taylor(expData, h, 6);
tf2tex(Fs_taylor_1d{1}, "\\widetilde{G}_\\varphi", 'G_1d_taylor_cont', 5);
tf2tex(c2d(Fs_taylor_1d{1}, Ts, 'zoh'), "\\widetilde{G}_\\varphi", ...
    'G_1d_taylor_disc', 5);

% Pade 1D
[~, Fs_pade_1d] = model_1d_pade(expData, h, 6);
tf2tex(Fs_pade_1d{1}, "\\widetilde{G}_\\varphi", 'G_1d_pade_cont', 5);
tf2tex(c2d(Fs_pade_1d{1}, Ts, 'zoh'), "\\widetilde{G}_\\varphi", ...
    'G_1d_pade_disc', 5);


%% Fin de l'analyse
msg = 'Press any key to continue...';
input(msg);
fprintf(repmat('\b', 1, length(msg)+1)+"\n");
close all;
