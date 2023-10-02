clear; close all;
%% Inputs and definitions
analysisName = 'sys1_resFlu'; % Analysis name
identNumber = 1;              % Number for the experiment to be used
maxOrderConv = 10;            % Maximum order for the convergence analysis 
delayOrders = [7 9 12];       % Delay orders value

% Final model orders
finalOrder.OE = 6;
finalOrder.ARX = 6;
finalOrder.ARMAX = 9;
finalOrder.BJ = 4;

fprintf("<strong>Identification analysis</strong>\n");

%% Output directory verification and multidimentional analysis

disp("Loading variables.");
analysis = analysisSettings(analysisName, direct=true);
load("..\database\convertedData\" + analysisName + ".mat");

% Identification and validation data sets
identData = expData.getexp(identNumber);
validData = expData.getexp(setdiff(expData.isPRBS, identNumber));

%% Main

% Delay analysis
disp("Delay analysis.");
find_delay(expData, analysis); close all;

% Steady-state
disp("Steady-state analysis.");
%steadyState(expData);

% Analysis for the convergence of models
disp("Convergence analysis.");
modelsBack = convergence(identData, maxOrderConv, delayOrders, type=1, ...
    finalOrder=4);
%convergenceDelay(identData, [3 10], modelsBack, type=1);
% convergenceDelay(identData, [7 12], modelsBack, type=1);
% modelsFront = convergence(identData, maxOrderConv, 0, type=2);

% Residuals analysis
disp("Analysis for the residuals.");
residuesBack = validation(validData, modelsBack, type=1);
%residuesFront = validation(validData, modelsFront, type=2);

% Model inversion
disp("Inverting models ARX and ARMAX");
resid = inversion(expData, modelsBack, 10);
