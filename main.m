clc;
%% Fichier main

fprintf("<strong>ANALYSE PAR LE FICHIER MAIN</strong>\n\n");
% Prendre la conversion de variables
run("database\convertData.m");

% Fait l'analyse fréquencielle
run("freqAnalysis\main_freqAnalysis.m");

% Fait l'analyse d'identification
run("identification\main_identification.m");