clc; clear; close all;
%% Entrées
maxOrder = 20;              % [-] Ordre maximale pour la convergence ;
delayOrders = [0 10 20];    % [-] Ordre du retard ;
expToBeAnalysed = 1;        % [-] Numéro du teste a être analysé ;

% Paramètres de la simulation
analysisName = 'sys1_isoPla';          % [-] Nom de l'analyse ;
dataDir = '..\dataBase\convertedData'; % [-] Dossier pour les données ;
figDir = 'outFig';                     % [-] Dossier pour les figures ;
colors = ['r','g','b','k'];            % [-] Couleurs des graphiques ;
linSty = ["-"; "--"; "-."; ":"]; % [-] Type de trace pour des graphiques ;

%% Preparation de données et fichiers
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

% Prendre le jeux des données
run("..\dataBase\convertData.m");
load(dataDir + "\" + analysisName);

% Paramètres des modèles
arxOpt = arxOptions('Focus', 'simulation');
armaxOpt = armaxOptions('Focus', 'simulation');

% Données d'identification (utilise le première experiment)
identData = getexp(expData, expToBeAnalysed);

% Initialization des variables
J_oe = zeros(1, maxOrder);
J_arx = zeros(1, maxOrder);
J_armax = zeros(1, maxOrder);

%% Convergence d'ordre des modèles

fig = figure;

for i = 1:length(delayOrders)
    for order = 1:maxOrder

        % Modèle ARX
        sysARX = arx(identData, [order, order, delayOrders(i)], arxOpt);
        y_arx = lsim(sysARX, identData.u);
        J_arx(order) = 20*log10(sysARX.report.Fit.LossFcn);

        % Initialisation de la optimization - non linéaire
        if order == 1
            sys_init_oe = idpoly(1, sysARX.B, 1, 1, sysARX.A, ...
                sysARX.NoiseVariance, sysARX.Ts);
            sys_init_armax = idpoly(1, sysARX.B, 1, 1, sysARX.A, ...
                sysARX.NoiseVariance, sysARX.Ts);
        else
            sys_init_oe = idpoly(1, [sysOE.B 0], 1, 1, [sysARX.F 0], ...
                sysARX.NoiseVariance, sysOE.Ts);
            sys_init_armax = idpoly([sysARMAX.A 0], [sysARMAX.B 0], ...
                [sysARX.C 0], 1, 1, sysARX.NoiseVariance, sysARMAX.Ts);
        end

        % Modèle OE
        sys_init_oe.TimeUnit = 'milliseconds';
        sysOE = oe(identData, sys_init_oe);
        y_oe = lsim(sysOE, identData.u);
        J_oe(order) = 20*log10(sysOE.report.Fit.LossFcn);        

        % Modèle ARMAX
        sys_init_armax.TimeUnit = 'milliseconds';
        sysARMAX = armax(identData, sys_init_armax);
        y_armax = lsim(sysARMAX, identData.u);
        J_armax(order) = 20*log10(sysARMAX.report.Fit.LossFcn);
    end
    subplot(3, 1, 1);  hold on;
    plot(1:maxOrder,  J_oe, colors(i), LineStyle=linSty(i), ...
        LineWidth=1.4, DisplayName="$n_k = "+num2str(delayOrders(i))+"$");
    subplot(3, 1, 2);  hold on;
    plot(1:maxOrder, J_arx, colors(i), LineStyle=linSty(i), ...
        LineWidth=1.4, HandleVisibility='off');
    subplot(3, 1, 3);  hold on;
    plot(1:maxOrder, J_armax, colors(i), LineStyle=linSty(i), ...
        LineWidth=1.4, HandleVisibility='off');
end
subplot(3, 1, 1);  hold off; grid minor;
%legend(Interpreter="latex", FontSize=17, Location="best");
ylabel("Mod\`{e}le OE", Interpreter="latex", FontSize=17);
subplot(3, 1, 2);  hold off; grid minor;
ylabel("Mod\`{e}le ARX", Interpreter="latex", FontSize=17);
subplot(3, 1, 3);  hold off; grid minor;
ylabel("Mod\`{e}le ARMAX", Interpreter="latex", FontSize=17);
xlabel("Ordre $n_a = n_b$", Interpreter="latex", FontSize=17);
%fig.Position = [558 258 815 582];
fig.Position = [296 90 769 570];
saveas(fig, figDir+"\"+analysisName+"\orderIdent_poly.eps");
sgtitle("Analyse de convergence", ...
    Interpreter="latex", FontSize=20);