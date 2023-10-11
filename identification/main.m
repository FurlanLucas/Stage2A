clear; close all;
%% Inputs and definitions
analysisName = 'sys2_resFlu'; % Analysis name
identNumber = 1;              % Number for the experiment to be used
maxOrderConv = 10;            % Maximum order for the convergence analysis 
%delayOrders = [7 9 12];      % Delay orders value of heat flux analysis sys1_resFlu
delayOrders = [2 3 4];       % Delay orders value of heat temp analysis sys2_resFlu

% Final model orders
finalOrder.OE = 5;
finalOrder.ARX = 5;
finalOrder.ARMAX = 5;
finalOrder.BJ = 4;
delayOrder = 9; 

fprintf("<strong>Identification analysis</strong>\n");

%% Output directory verification and multidimentional analysis

disp("Loading variables.");
analysis = analysisSettings(analysisName, direct=true);
load("..\database\convertedData\" + analysisName + ".mat");

% Identification and validation data sets
identData = expData.getexp(expData.isPRBS(identNumber));
validData = expData.getexp(setdiff(expData.isPRBS, identNumber));

%% Main

% Delay analysis
disp("Delay analysis.");
%find_delay(expData, analysis); close all;

% Steady-state
disp("Steady-state analysis.");
%steadyState(expData, analysis);

% Analysis for the convergence of models
disp("Convergence analysis.");
modelsBack = convergence(identData, analysis, maxOrderConv, ...
    delayOrders, type=1, finalOrder=finalOrder);
convergenceDelay(identData, analysis, [3 10], modelsBack, type=1);
modelsFront = convergence(identData, analysis, maxOrderConv, ...
    delayOrders, type=2, finalOrder=finalOrder);
convergenceDelay(identData, analysis, [3 10], modelsBack, type=1);

% Residuals analysis
disp("Analysis for the residuals.");
residuesBack = validation(validData, analysis, modelsBack, type=1);
residuesFront = validation(validData, analysis, modelsFront, type=2);

% Model inversion
disp("Inverting models ARX and ARMAX");
inversion(expData, analysis, modelsBack, modelsFront);
