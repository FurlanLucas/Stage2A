clc; clear; close all;
%% Entrées et définitions
figDir = 'outFig';            % [-] Emplacement pour les figures générées ;
analysisName = 'sys1_polBas'; % [-] Non de l'analyse a être réalisé ;
identNumber = 5;              % [-] Numéro du experiment a être analysé ;

%% Vérification de sortie et chargement des données
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

% Prendre les données (et des autres configurations du matlab)
addpath('..\freqAnalysis'); % Pour le fichier de definition de sysDataType
addpath('..\dataBase'); % Pour prendre la base de données
run('..\database\convertData.m'); % Prendre les nouveaux jeux si possible
load("..\database\convertedData\" + analysisName + ".mat");

% Données de identification et validation
n_data = size(expData, 4); % Nombre des exp réalisés ;
identData = getexp(expData, identNumber);
validData = getexp(expData, setdiff(1:n_data, identNumber));

%% Main

% Compaire les modèles avec les résultats théoriques
disp("Analyse de comparaison avec les modèles théoriques.");
compare_results(identData);

% Analyse de convergence des modèles
disp("Analyse de convergence des modèles.");
models = convergence(expData, maxOrderConv, delayOrders);

% Analyse des residues
disp("Analyse des residues des modèles obtenus.");
residues = validation(expData, models);
