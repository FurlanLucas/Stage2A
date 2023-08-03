clc; close all; clear;
%% Entrées et définitions
figDir = 'outFig';            % [-] Emplacement pour les figures générées ;
analysisName = 'sys1_polBas'; % [-] Non de l'analyse a être réalisé ;
identNumber = 5;              % [-] Numéro du experiment a être analysé ;

%% Vérification de sortie et chargement des données
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

% Prendre les données (et des autres configurations du matlab)
disp("Acquisition et convertion des données en cours.");
addpath('..\freqAnalysis'); % Pour le fichier de definition de sysDataType
addpath('..\dataBase'); % Pour prendre la base de données
run('..\database\convertData.m'); % Prendre les nouveaux jeux si possible
load("..\database\convertedData\" + analysisName + ".mat");

% Données de identification et validation
n_data = size(expData, 4); % Nombre des exp réalisés ;
identData = getexp(expData, identNumber);

%%
load('models', 'models');
H = tf(models.ARX.B, models.ARX.A, models.ARX.Ts/1e3);

% Prendre les zéros unstables
zeros = zpk(models.ARX).Z{1}; zeros = zeros(abs(zeros)>=1);

% Passe tous
G = zpk(zeros, 1./conj(zeros), 1/real(prod(-zeros)), models.ARX.Ts/1e3);
figure, bode(G);

% Nouvelle version
HH = minreal(H/G);
figure, pzplot(HH);

% Bode
figure, bode(H, 'r', HH, 'b'); title("Normale");
figure, bode(1/H, 'r', 1/HH, 'b'); title("Inverse");

% Sim
y_arx = lsim(H, identData.u, identData.SamplingInstants/1e3);
y_arx2 = lsim(HH, identData.u, identData.SamplingInstants/1e3);
figure, plot(identData.y, 'r'); hold on; plot(y_arx, 'b', LineWidth=1.7);
plot(y_arx2, 'g', LineWidth=1.7);

% Sim
y_arx = lsim(1/HH, identData.y, identData.SamplingInstants/1e3, 'b');
figure, plot(y_arx); hold on; plot(identData.u, 'r');


