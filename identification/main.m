clc; clear; close all;
%% Entrée
Ts = 10;        % [ms] Temps d'échantillonage ;
maxOrder = 15;  % [-] Ordre maximale pour la convergence ;

% Paramètres de la simulation
dataDir = 'data_exp';       % [-] Emplacement pour les données ;
figDir = 'fig';             % [-] Emplacement pour les figures ;
Fs_theory = 'Fs_pade';      % [-] Fonction de transfert théorique (Pade) ; 
delayOrders = [1 3 5];      % [-] Ordre du retard ;
colors = ['r', 'b', 'k', 'g'];

%% Idetification avec le modèle OE du polysterène 
identData = readtable(dataDir + "\polyA.xlsx"); % Données d'identification;
identData.y = identData.y - identData.y(1);

fig = figure; hold on; % Figure de convergence
for i = 1:length(delayOrders)
    error = zeros(1, maxOrder);
    for order = 1:maxOrder
        sysOE = oe(identData.u, identData.y, [order, order, i]);
        sysOE.Ts = 10;
        y_oe = predict(sysOE, iddata(identData.y,identData.u,Ts)).OutputData;
        error(order) = 20*log(sum((y_oe - identData.y).^2)); 
    end
    plot(1:maxOrder, error, colors(i));
end

% Figure des données d'entrée (identification)
fig = figure; subplot(2,1,1);
plot(identData.t/1e3, identData.y, 'b', LineWidth=.5, DisplayName='$Y$');
ylabel('y(t)', Interpreter="latex", FontSize=17);
grid minor; subplot(2,1,2);
plot(identData.t/1e3, identData.u, 'r', LineWidth=1.4);
ylabel('u(t)', Interpreter="latex", FontSize=17);
xlabel('Temps (s)', Interpreter='latex', FontSize=17);
grid minor; fig.Position = [294 223 756 340];
saveas(fig, figDir+"\inputIdent_poly.png");
sgtitle("Donn\'{e}es d'identification (polyster\'{e}ne)", ...
    Interpreter="latex", FontSize=20);

% Modèle OE 
sysOE = oe(identData.u, identData.y, [11, 11, 0]);
sysOE.Ts = 10;

% Predict
load(Fs_theory)
y_oe = lsim(sysOE, identData.u, identData.t);
y_oe2 = predict(sysOE, iddata(identData.y,identData.u,Ts));
y_theory = lsim(Fs_approx, identData.u, identData.t);
y_theory = y_theory*(mean(y_oe)/mean(y_theory));

% Figure (compaire)
fig = figure; hold on;
plot(identData.t/1e3, identData.y, 'k', LineWidth=0.5, ...
    DisplayName="Donn\'{e}es"); 
plot(identData.t/1e3, y_oe, 'r', LineWidth=1.4, ...
    DisplayName='Model');
plot(identData.t/1e3, y_oe2.OutputData, 'g', LineStyle=':', LineWidth=1.4, ...
    DisplayName='Model2');
plot(identData.t/1e3, y_theory, 'b', LineWidth=1.4, ...
    DisplayName="Th\'{e}orique");
ylabel('Mag', Interpreter='latex', FontSize=17);
xlabel('Temps (s)', Interpreter='latex', FontSize=17);
grid minor; legend(Interpreter="latex", FontSize=12, Location="northwest");
saveas(fig, figDir+"\ident_poly.png");
title({"Donn\'{e}es de validation pour le", "mod\'{e}le OE " + ...
    "(polyster\`{e}ne)"}, Interpreter="latex", FontSize=20);

% Données de validation
validData1 = readtable(dataDir + "\polyS.xlsx"); % Données de validation
validData1.y = validData1.y - validData1.y(1);
validData2 = readtable(dataDir + "\polyS2.xlsx"); % Données de validation
validData2.y = validData2.y - validData2.y(1);

% Predict
y_oe1 = lsim(sysOE, validData1.u, validData1.t);
y_oe2 = lsim(sysOE, validData2.u, validData2.t);
% y_oe1 = predict(sysOE, iddata(validData1.y,validData1.u,Ts));
% y_oe2 = predict(sysOE, iddata(validData2.y,validData2.u,Ts));
% y_oe1 = y_oe1.OutputData;
% y_oe2 = y_oe2.OutputData;

% Figure (compaire)
fig = figure; subplot(2, 1, 1); hold on;
plot(validData1.t/1e3, validData1.y, 'k', LineWidth=1.4, ...
    DisplayName="Donn\'{e}es");
plot(validData1.t/1e3, y_oe1, 'r', LineWidth=1.4, DisplayName='Model');
grid minor; hold off; subplot(2,1,2); hold on;
plot(validData2.t/1e3, validData2.y, 'k', LineWidth=1.4, ...
    DisplayName="Donn\'{e}es");
plot(validData2.t/1e3, y_oe2, 'r', LineWidth=1.4, DisplayName='Model');
ylabel('Mag', Interpreter='latex', FontSize=17);
xlabel('Temps (s)', Interpreter='latex', FontSize=17);
hold off; grid minor; 
legend(Interpreter="latex", FontSize=12, Location="northwest");
saveas(fig, figDir+"\valid_poly.png");
sgtitle({"Donn\'{e}es de validation pour le", "mod\'{e}le OE " + ...
    "(polyster\`{e}ne)"}, Interpreter="latex", FontSize=20);

% Clear the memory
clear validData2 validData2 identData;

%% Idetification avec le modèle ARX du polysterène 
identData = readtable(dataDir + "\polyA.xlsx"); % Données d'identification;
identData.y = identData.y - identData.y(1);

% Modèle ARX 
sysARX = arx(identData.u, identData.y, [11, 11, 0]);
sysARX.Ts = 10;

% Predict
load(Fs_theory)
y_arx = lsim(sysARX, identData.u, identData.t);
y_theory = lsim(Fs_approx, identData.u, identData.t);
y_theory = y_theory*(mean(y_arx)/mean(y_theory));

% Figure (compaire)
fig = figure; hold on;
plot(identData.t/1e3, identData.y, 'k', LineWidth=0.5, ...
    DisplayName="Donn\'{e}es"); 
plot(identData.t/1e3, y_oe, 'r', LineWidth=1.4, ...
    DisplayName='Model');
plot(identData.t/1e3, y_theory, 'b', LineWidth=1.4, ...
    DisplayName="Th\'{e}orique");
ylabel('Mag', Interpreter='latex', FontSize=17);
xlabel('Temps (s)', Interpreter='latex', FontSize=17);
grid minor; legend(Interpreter="latex", FontSize=12, Location="northwest");
saveas(fig, figDir+"\ident_poly.png");
title({"Donn\'{e}es d'identification pour le", "mod\'{e}le ARX " + ...
    "(polyster\`{e}ne)"}, Interpreter="latex", FontSize=20);

% Données de validation
validData1 = readtable(dataDir + "\polyS.xlsx"); % Données de validation
validData1.y = validData1.y - validData1.y(1);
validData2 = readtable(dataDir + "\polyS2.xlsx"); % Données de validation
validData2.y = validData2.y - validData2.y(1);

% Predict
y_arx1 = lsim(sysARX, validData1.u, validData1.t);
y_arx2 = lsim(sysARX, validData2.u, validData2.t);

% Figure (compaire)
fig = figure; subplot(2, 1, 1); hold on;
plot(validData1.t/1e3, validData1.y, 'k', LineWidth=1.4, ...
    DisplayName="Donn\'{e}es");
plot(validData1.t/1e3, y_arx1, 'r', LineWidth=1.4, DisplayName='Model');
grid minor; hold off; subplot(2,1,2); hold on;
plot(validData2.t/1e3, validData2.y, 'k', LineWidth=1.4, ...
    DisplayName="Donn\'{e}es");
plot(validData2.t/1e3, y_arx2, 'r', LineWidth=1.4, DisplayName='Model');
ylabel('Mag', Interpreter='latex', FontSize=17);
xlabel('Temps (s)', Interpreter='latex', FontSize=17);
hold off; grid minor; 
legend(Interpreter="latex", FontSize=12, Location="northwest");
saveas(fig, figDir+"\valid_poly.png");
sgtitle({"Donn\'{e}es de validation pour le", "mod\'{e}le ARX " + ...
    "(polyster\`{e}ne)"}, Interpreter="latex", FontSize=20);