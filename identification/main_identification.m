clear; close all;
%% Inputs and definitions
figDir = 'outFig';            % Directory for output figures
analysisName = 'sys1_isoBas'; % Analysis name
identNumber = 1;                % Number for the experiment to be used
maxOrderConv = 10;            % Maximum order for the convergence analysis 
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
n_data = length(expData.v); % Number of experiments done
identData = expData.getexp(identNumber);
validData = expData.getexp(setdiff(1:n_data, identNumber));

%% Main

% Compaire the experimental results with the theorical models
disp("Comparison with theorical and numerical results.");
compare_results(expData, h=20);

% Delay analysis
disp("Delay analysis.");
delay = find_delay(expData); close all;

% Analysis for the convergence of models
disp("Convergence analysis.");
models = convergence(validData, maxOrderConv, 0);

% Residuals analysis
disp("Analysis for the residuals.");
residues = validation(expData, models);
