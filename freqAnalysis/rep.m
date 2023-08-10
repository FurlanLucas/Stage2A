clc; clear; close all;
%% Entrées et définitions
figDir = 'outFig';            % [-] Emplacement pour les figures générées ;
analysisName = 'sys1_isoBas'; % [-] Non de l'analyse a être réalisé ;
expNumber = 1;                % [-] Numéro du experiment a être analysé ;
numberOfZeros = 7;            % [-] Numéro de zéros de l'analyse ;
points = 1000;                % [-] Points pour l'analyse ;

% Coefficients phisiques
hr2 = 15;           % [-] Coefficient de transfert thermique en r = Rmax ;
Rmax = 30e-3;       % [-] Rayon de thermocouple ;
lambda_r = 15;      % [-] Conductivité thermique dans la direction r ;

%% Vérification de sortie et chargement des données
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

addpath('..\database'); % Pour le fichier de definition de sysDataType
load("..\database\convertedData\" + analysisName + ".mat");
expData = getexp(expData, expNumber);

%% Solutions de l'équation transcendente

% Prendre les solutions pour alpha_n (dans la direction y)
load("J_roots.mat", 'J0', 'J1');

f = @(alpha_n) hr2*besselj(0,alpha_n*Rmax) - ...
    lambda_r*besselj(1,alpha_n*Rmax).*alpha_n;

alpha = zeros(numberOfZeros+1, 1);

alpha(1) = bissec(f, 0, J0(1)/Rmax);
for i = 1:numberOfZeros
   alpha(i+1) = bissec(f, J1(i)/Rmax, J0(i+1)/Rmax);
end

Nalpha = ((Rmax^2) / 2) * (besselj(0, alpha*Rmax) .^ 2);

%% Figure

figAlpha = linspace(0, alpha(end), points);

fig = figure; hold on;
plot(figAlpha, f(figAlpha), 'b',DisplayName="$f(x)-g(x)$",LineWidth=1.5);
plot(alpha, f(alpha), 'or', MarkerFaceColor='r', MarkerSize=8, ...
    DisplayName="Racines trouv\'{e}es");
xlabel("$x$", Interpreter="latex", FontSize=17);
ylabel("Amplitude", Interpreter="latex", FontSize=17);
legend(Location="SouthWest",Interpreter="latex", FontSize=17); 
grid minor;
saveas(fig, figDir+"\"+analysisName+"\roots_bessel.eps", 'epsc');
title("Calcule des racines",Interpreter="latex", FontSize=23);
