clc; clear; close all;
%% Entrées et configurations
figDir = 'outFig';         % [-] Emplacement pour les figures générées ;
fileDataName = 'reentryData.csv'; % [-] Nom du fichier des données ;
analysisName = 'sys1_isoBas';  % [-] Non de l'analyse a être réalisé ;
maxOrderConv = 10;   % [-] Ordre maximale dans l'analyse de convergence ; 
delayOrders = 1;               % [-] Ordre de retard à être analysée ;
identNumber = 1;               % [-] Num. du experiment (identification) ;
validNumber = 2;               % [-] Num. du experiment (validation) ;
fs = 1;                        % [s] Fréquence d'échantillonage ;

%% Données expérimentales et sorties

if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end


%% Prendre les données de l'Onera et ceux expérimentales

disp("Prends les données d'entrée.");
%addpath('..\dataBase'); % Pour prendre la base de données
load("..\database\convertedData\" + analysisName + ".mat");
expData = transformInput(expData);

% Données d'identification
identData = getexp(expData, identNumber);

% Données de l'Onera
[phi, t] = takeExpFlux(fileDataName);

%% Identification du retard

disp("Identification du retard.");
delay = find_delay(identData);

%% Identification de la dynamique du capteur

disp("Analyse de convergence.");
models = convergence(identData, maxOrderConv, delay);
close all;

%% Validation des données

disp("Analyse de convergence.");
resid = validation(expData, models);

%% Inverse

disp("Analyse des modèles inverses.");
inversedModels = inverse(models, getexp(expData, 2));
close all;

%% Test l'inverse et cree la sortie

disp("Cree les donnees inverses.");
signal = createTensionSignal(inversedModels, phi, t, fs);

