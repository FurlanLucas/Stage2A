clc; clear; close all;
%% rep
%
%   Gerenerates the figure of the first roots of the eigen value equation
%   in cylindrical coordenates. It uses the same code as the model___.m
%   files.

%% Inputs and definitions
figDir = 'outFig';            % Directory for output figures
analysisName = 'sys1_isoBas'; % Analysis name
expNumber = 1;                % Number for the experiment to be used
numberOfZeros = 7;            % Number of zeros to be found
points = 1000;                % Number of points in the graph

% Phisical coefficients
hr2 = 15;           % [W/(m²K)] Heat transfert coefficient
Rmax = 30e-3;       % [m] Thermocouple size
lambda_r = 15;      % [W/mK] Thermal conductivity in r direction

%% %% Output directory verification and variable loads
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

addpath('..\database'); % To define the thermalData and sysDataType variables
load("..\database\convertedData\" + analysisName + ".mat");
expData = getexp(expData, expNumber);

%% Eigen value equation roots

% Prendre les solutions pour alpha_n (dans la direction y)
load("J_roots.mat", 'J0', 'J1');

f = @(alpha_n) hr2*besselj(0,alpha_n*Rmax) - ...
    lambda_r*besselj(1,alpha_n*Rmax).*alpha_n;

alpha = zeros(numberOfZeros+1, 1);

alpha(1) = bisec(f, 0, J0(1)/Rmax);
for i = 1:numberOfZeros
   alpha(i+1) = bisec(f, J1(i)/Rmax, J0(i+1)/Rmax);
end

Nalpha = ((Rmax^2) / 2) * (besselj(0, alpha*Rmax) .^ 2);

%% Figure

figAlpha = linspace(0, alpha(end), points);

% Figure in english
fig = figure; hold on;
plot(figAlpha, f(figAlpha), 'b',DisplayName="$(f-g)(x)$",LineWidth=1.5);
p = plot(alpha, f(alpha), 'or', MarkerFaceColor='r', MarkerSize=8, ...
    DisplayName="Found roots");
xlabel("$x$", Interpreter="latex", FontSize=17);
ylabel("Amplitude", Interpreter="latex", FontSize=17);
legend(Location="SouthWest",Interpreter="latex", FontSize=17); 
grid minor;
saveas(fig, figDir+"\"+analysisName+"\roots_bessel.eps", 'epsc');

% Figure in french
set(p, "DisplayName", "Racines trouv\'{e}es");
grid minor;
saveas(fig, figDir+"\"+analysisName+"\roots_bessel_en.eps", 'epsc');
title("Calcule des racines",Interpreter="latex", FontSize=23);
