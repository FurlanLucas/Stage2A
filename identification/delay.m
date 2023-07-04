clc; clear; close all;
%% Entrées et paramètres

% Paramètres de la simulation
analysisName = 'sys1_isoPla';          % [-] Nom de l'analyse ;
dataDir = '..\dataBase\convertedData'; % [-] Dossier pour les données ;
figDir = 'outFig';                     % [-] Dossier pour les figures ;

%% Preparation de données et fichiers
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

% Prendre le jeux des données
run("..\dataBase\convertData.m");
load(dataDir + "\" + analysisName);

% Nombre des jeux des données differents
n_data = size(expData, 4);

%% Avec la function delayest
fprintf("Analyse du retard pour %s:\n", analysisName);

for i = 1:n_data
    data = getexp(expData, i);
    nk = delayest(data);
    fprintf("\tPour le jeux %s : nk = %d ;\n", data.ExperimentName{1}, nk)
end
disp(' ');

%% Graphiquement

for i = 1:n_data
    data = getexp(expData, i);
    h = impulseest(data, 40);
    figure, showConfidence(impulseplot(h))
end


