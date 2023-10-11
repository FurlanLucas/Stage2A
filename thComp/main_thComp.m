clear; close all;
%% Inputs and definitions
figDir = 'figOut';            % Directory for output figures
analysisName = 'sys2_resFlu'; % Analysis name
identNumber = 1;              % Number for the experiment to be used
maxOrderConv = 10;            % Maximum order for the convergence analysis 
delayOrders = [6 10 14];    % Delay orders value

% Final model orders
finalOrder.OE = 6;
finalOrder.ARX = 6;
finalOrder.ARMAX = 9;
finalOrder.BJ = 4;

fprintf("<strong>Analytical and numerical comparisons</strong>\n");

%% Output directory verification and multidimentional analysis
if not(isfolder(figDir))
    mkdir(figDir);
end

% Take the data
disp("Loading variables.");
addpath('..\freqAnalysis'); % For the class definitions
addpath('..\dataBase'); % For the database
load("..\database\convertedData\" + analysisName + ".mat");

% Identification data
identData = getexp(expData, identNumber);

%% Main

% Convergence of finite  1D
disp('Analysis of finite difference convergence.');
%convergenceFinDiff(expData.sysData);

% Th. comparison
disp('Compaire all models.');
compare_results(expData, h=9);


