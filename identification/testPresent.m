clc; clear; close all;
%% Entrées et définitions
figDir = 'outFig';            % [-] Emplacement pour les figures générées ;
analysisName = 'sys1_polBas'; % [-] Non de l'analyse a être réalisé ;
identNumber = 1;              % [-] Numéro du experiment a être analysé ;
maxOrderConv = 10;   % [-] Ordre maximale dans l'analyse de convergence ; 
delayOrders = [0 20 10];      % [-] Ordre de retard à être analysée ;

%% Vérification de sortie et chargement des données
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

% Prendre les données (et des autres configurations du matlab)
disp("Acquisition et convertion des données en cours.");
addpath('..\freqAnalysis'); % Pour le fichier de definition de sysDataType
addpath('..\dataBase'); % Pour prendre la base de données
%run('..\database\convertData.m'); % Prendre les nouveaux jeux si possible
load("..\database\convertedData\" + analysisName + ".mat");

% Données de identification et validation
n_data = size(expData, 4); % Nombre des exp réalisés ;
identData = getexp(expData, identNumber);
identData.Notes = identData.Notes{identNumber};
validData = getexp(expData, setdiff(1:n_data, identNumber));

%%
fig = figure;
subplot(2, 1, 1);
plot(identData.SamplingInstants/60e3, identData.u, 'r', LineWidth=1.5);
grid minor; 
ylabel({"Flux de chaleur", "en d'entr\'{e}e $(W/m^2)$"}, ...
    Interpreter="latex", FontSize=17);
subplot(2, 1, 2);
plot(identData.SamplingInstants/60e3, identData.Notes, 'b', LineWidth=1.5);
ylabel("Tension d'entr\'{e}e (V)",Interpreter="latex",FontSize=17);
xlabel("Temps (min)",Interpreter="latex",FontSize=17);
grid minor; fig.Position = [385 108 611 462];
saveas(fig, "Chenge_to_flux.eps", 'epsc');

%% regime permanente
opts = delimitedTextImportOptions("Delimiter", '\t', 'VariableNames', ... 
    {'t', 'y', 'v', 'phi'});
dataRead = readtable("steady_state0003.txt",opts); 
y = str2double(strrep(dataRead.y(4:end), ',', '.'));
phi = str2double(strrep(dataRead.phi(4:end,1), ',', '.')); 
t = str2double(strrep(dataRead.t(4:end,1), ',', '.'));
y = y/(identData.UserData.Ytr*1e-6);
phi = phi/(identData.UserData.Vq*1e-6);

fig = figure();
plot(t/(3600e3), y, 'b', LineWidth=0.5); grid minor;
ylabel("$\Delta$ Temp\'{e}rature ($^\circ$C)",Interpreter="latex",FontSize=17);
xlabel("Temps (h)",Interpreter="latex",FontSize=17);
saveas(fig, "Permanent.eps", 'epsc');

M = 500;
sres = pi*(30e-3)^2;
s = pi*(75e-3/2)^2;
PHI = mean(phi(end-M:end));
TEMP = mean(y(end-M:end));
h = sres*PHI/(s*TEMP)

