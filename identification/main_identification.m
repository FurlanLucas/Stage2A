clear; close all;
%% Inputs and definitions
figDir = 'outFig';            % Directory for output figures
analysisName = 'sys1_isoBas'; % Analysis name
identNumber = 1;                % Number for the experiment to be used
maxOrderConv = 5;            % Maximum order for the convergence analysis 
delayOrders = [0 20 10];      % Delay orders value

fprintf("<strong>Identification analysis</strong>\n");

%% Output directory verification and multidimentional analysis
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

% Take the data
disp("Loading variables.");
addpath('..\freqAnalysis'); % For the class definitions
addpath('..\dataBase'); % For the database
load("..\database\convertedData\" + analysisName + ".mat");

% Identification and validation data sets
identData = expData.getexp(identNumber);
validData = expData.getexp(setdiff(1:expData.Ne, identNumber));

%% Main

% Compaire the experimental results with the theorical models
disp("Comparison with theorical and numerical results.");
compare_results(expData, h=17);

% Delay analysis
disp("Delay analysis.");
delay = find_delay(expData); close all;

% Steady-state
disp("Steady state-analysis.");
steadyState(expData);

% Analysis for the convergence of models
disp("Convergence analysis.");
models = convergence(identData, maxOrderConv, 0);

% Residuals analysis
disp("Analysis for the residuals.");
residues = validation(validData, models);

% Model inversion
disp("Inverting models ARX and ARMAX");
inversion(expData, models);