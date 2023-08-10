clear; close all;
%% Entrées et définitions
figDir = 'outFig';            % [-] Emplacement pour les figures générées ;
analysisName = 'sys1_isoBas'; % [-] Non de l'analyse a être réalisé ;
identNumber = 1;              % [-] Numéro du experiment a être analysé ;
maxOrderConv = 10;   % [-] Ordre maximale dans l'analyse de convergence ; 
delayOrders = [0 20 10];      % [-] Ordre de retard à être analysée ;

fprintf("<strong>Analyse d'identification</strong>\n");

%% Vérification de sortie et chargement des données
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

% Prendre les données (et des autres configurations du matlab)
disp("Chargement des variables.");
addpath('..\freqAnalysis'); % Pour le fichier de definition de sysDataType
addpath('..\dataBase'); % Pour prendre la base de données
load("..\database\convertedData\" + analysisName + ".mat");

% Données de identification et validation
n_data = size(expData, 4); % Nombre des exp réalisés ;
identData = expData.getexp(identNumber);
validData = expData.getexp(setdiff(1:n_data, identNumber));

%% Main

% Compaire les modèles avec les résultats théoriques
disp("Analyse de comparaison avec les modèles théoriques.");
compare_results(identData, h=15);

% Analyse du delay des modèles
disp("Analyse du delay du système.");
delay = find_delay(expData); close all;

% Analyse de convergence des modèles
disp("Analyse de convergence des modèles.");
models = convergence(validData, maxOrderConv, 0);

% Analyse des residues
disp("Analyse des residues des modèles obtenus.");
residues = validation(expData, models);
