clc; clear; close all;
%% Entrées
Ts = 10;                % [ms] Temps d'échantillonage ;
maxOrder = 10;          % [-] Ordre maximale pour la convergence ;
delayOrders = [1 5 10];  % [-] Ordre du retard ;
midOrder = 50;          % [-] Mid order ;

% Paramètres de la simulation
analysisName = 'testNewDataPoly'; % [-] Nom de l'analyse ;
%dataDir = 'oldData';          % [-] Directoire pour les données ;
dataDir = 'myData';           % [-] Directoire pour les données ;
figDir = 'fig';               % [-] Directoire pour les figures ;
colors = ['r','b','k','g'];   % [-] Couleurs des graphiques ;
linSty = ["--"; ":"; "-."];   % [-] Type de trace pour des graphiques ;
%identDataName = "polyA.xlsx"; % Données pour la validation ;
identDataName = "sys1_isoPlac_01.txt"; % Données pour la validation ;

% Données pour la validation
%validDataNames = ["polyS.xlsx", "polyS2.xlsx"];
validDataNames = "sys1_isoPlac_02.txt";

%% Preparation de données et fichiers
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

%% Idetification du système avec polysterène - modèles OE et ARX

% Données d'identification;
dataRead = readtable(dataDir + "\" + identDataName); 
dataRead.y = medfilt1(dataRead.y - dataRead.y(1), midOrder);
identData = iddata(dataRead.y, dataRead.u, Ts);

J_oe = zeros(1, maxOrder);
J_arx = zeros(1, maxOrder);
J_armax = zeros(1, maxOrder);

fig = figure; hold on; % Figure de convergence
opt = simOptions('AddNoise',true);

for i = 1:length(delayOrders)
    for order = 1:maxOrder
        % Modèle OE
        sysOE = oe(identData, [order, order, delayOrders(i)]);
        %y_oe = lsim(sysOE, identData.u, identData.SamplingInstants);
        y_oe = sim(sysOE, identData.u, opt);
        J_oe(order) = 20*log(sum((y_oe-identData.OutputData).^2)* ...
            (1 + 0*order) / length(identData.OutputData) ); 

        % Modèle ARX
        sysARX = arx(identData, [order, order, delayOrders(i)]);
        %y_arx = lsim(sysARX, identData.u, identData.SamplingInstants);
        y_arx = sim(sysARX, identData.u, opt);
        J_arx(order) = 20*log(sum((y_arx-identData.OutputData).^2)* ...
            (1 + 0*order) / length(identData.OutputData) );

        % Modèle ARMAX
        sysARMAX = armax(identData, [order, order, order, delayOrders(i)]);
        %y_armax = lsim(sysARMAX, identData.u, identData.SamplingInstants);
        y_armax = sim(sysARMAX, identData.u, opt);
        J_armax(order) = 20*log(sum((y_armax-identData.OutputData).^2)* ...
            (1 + 0*order) / length(identData.OutputData) ); 
    end
    plot(1:maxOrder,  J_oe, colors(i), LineWidth=1.4, ...
        DisplayName="$n_k = "+num2str(delayOrders(i))+"$");
    plot(1:maxOrder, J_arx, colors(i), LineStyle='--', LineWidth=1.4, ...
        HandleVisibility='off');
    plot(1:maxOrder, J_armax, colors(i), LineStyle='-.', LineWidth=1.4, ...
        HandleVisibility='off');
end
grid minor;
legend(Interpreter="latex", FontSize=17, Location="best");
saveas(fig, figDir+"\"+analysisName+"\orderIdent_poly.png");
title("Analyse de convergence du polyster\'{e}ne", Interpreter="latex", ...
    FontSize=20);

% Figure des données d'entrée (identification)
fig = figure; subplot(2,1,1);
plot(identData.SamplingInstants/1e3, identData.y, 'b', LineWidth=.5, ...
    DisplayName='$Y$');
ylabel('y(t)', Interpreter="latex", FontSize=17);
grid minor; subplot(2,1,2);
plot(identData.SamplingInstants/1e3, identData.u, 'r', LineWidth=1.4);
ylabel('u(t)', Interpreter="latex", FontSize=17);
xlabel('Temps (s)', Interpreter='latex', FontSize=17);
grid minor; fig.Position = [294 223 756 340];
saveas(fig, figDir+"\"+analysisName+"\inputIdent_poly.png");
sgtitle("Donn\'{e}es d'identification (polyster\'{e}ne)", ...
    Interpreter="latex", FontSize=20);

% Figure (compaire)
fig = figure; hold on;
plot(identData.SamplingInstants/1e3, identData.y, 'k', LineWidth=0.5, ...
    DisplayName="Donn\'{e}es"); 
plot(identData.SamplingInstants/1e3, y_oe, 'r', LineWidth=1.4, ...
    DisplayName='Model OE');
plot(identData.SamplingInstants/1e3, y_arx, 'g', LineWidth=1.4, ...
    DisplayName='Model ARX');
plot(identData.SamplingInstants/1e3, y_armax, 'b', LineWidth=1.4, ...
    DisplayName='Model ARMAX');
ylabel('Mag', Interpreter='latex', FontSize=17);
xlabel('Temps (s)', Interpreter='latex', FontSize=17);
grid minor; legend(Interpreter="latex", FontSize=12, Location="northwest");
saveas(fig, figDir+"\"+analysisName+"\ident_poly.png");
title({"Donn\'{e}es d'identification pour le", "(polyster\`{e}ne)"}, ...
    Interpreter="latex", FontSize=20);

%% Validation du modèle avec polysterène - modèles OE et ARX

fig = figure; % Création de la Figure

% Données de validation;
for i=1:length(validDataNames)
    dataRead = readtable(dataDir + "\" + validDataNames(i)); 
    dataRead.y = medfilt1(dataRead.y - dataRead.y(1), midOrder);
    validData = iddata(dataRead.y, dataRead.u, Ts);

    % Predict
    y_oe = lsim(sysOE, validData.u, validData.SamplingInstants);
    y_arx = lsim(sysARX, validData.u, validData.SamplingInstants);
    y_armax = lsim(sysARMAX, validData.u, validData.SamplingInstants);

    % Figure
    subplot(length(validDataNames), 1, i); hold on;
    plot(validData.SamplingInstants/1e3, validData.y, 'k', ...
        LineWidth=1, DisplayName="Donn\'{e}es");
    plot(validData.SamplingInstants/1e3, y_oe, "-.r", LineWidth=1, ...
        DisplayName='Model OE');
    plot(validData.SamplingInstants/1e3, y_arx, "-.g", LineWidth=1, ...
        DisplayName='Model ARX');
    plot(validData.SamplingInstants/1e3, y_armax, "-.b", LineWidth=1, ...
        DisplayName='Model ARMAX');
    grid minor; 
    ylabel("Data "+num2str(i), Interpreter='latex', FontSize=17);
end

% Figure - configurations graphiques finales
xlabel('Temps (s)', Interpreter='latex', FontSize=17);
legend(Interpreter="latex", FontSize=12, Location="northwest");
saveas(fig, figDir+"\"+analysisName+"\valid_poly.png");
sgtitle({"Donn\'{e}es de validation pour le", "mod\'{e}le OE " + ...
    "(polyster\`{e}ne)"}, Interpreter="latex", FontSize=20);

