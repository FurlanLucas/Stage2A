clc; clear; close;
%% rep
%   Code file to create some images to the report
%

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

%% Main

meshPlot2d(expData, 1, 5, 8);