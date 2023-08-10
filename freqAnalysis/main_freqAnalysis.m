clear; close all;
%% Entrées et définitions
figDir = 'outFig';            % Emplacement pour les figures générées ;
analysisName = 'sys1_isoBas'; % Non de l'analyse a être réalisé ;
expNumber = 1;                % Numéro du experiment a être analysé ;
orders = [1 5 10];            % Ordres pour l'approximation de Pade ;
colors = ['r','b','g','m'];   % Couleurs pour les graphes des ordres ;
h_comp = [10, 20];            % Comparaison pour des valeurs de h ;
h = 15;                       % Valeur finale de h

fprintf("\n<strong>Analyse fréquentielle</strong>\n");

%% Vérification de sortie et chargement des données
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

disp("Chargement des variables.");
addpath('..\database'); % Pour le fichier de definition des classes
load("..\database\convertedData\" + analysisName + ".mat");

% Choix de l'analyse multidimensional
if strcmp(expData.sysData.Geometry, "Cylinder")
    model_multi = @(var1, var2, var3) model_2d(var1, var2, var3);
    model_multi_pade = @(var1, var2, var3, var4) model_2d_pade(var1, ...
        var2, var3, var4);
    model_multi_taylor = @(var1, var2, var3, var4) model_2d_taylor(var1,...
        var2,var3, var4);
    type = "2D";
elseif strcmp(expData.sysData.Geometry, "Cube")
    model_multi = @(var1, var2, var3) model_3d(var1, var2, var3);
    model_multi_pade = @(var1, var2, var3, var4) model_3d_pade(var1, ...
        var2, var3, var4);
    model_multi_taylor = @(var1, var2, var3, var4) model_3d_taylor(var1,...
        var2, var3, var4);
    type = "3D";
else
    error("Champs << Geometry >> invalide.");
end

%% Analyse 1D (avec une comparaison entre différentes valeurs de h)

disp("Analyse 1d avec différentes valeurs de h.");

results_1d1 = model_1d(expData, 5);
results_1d2 = model_1d(expData, 25);

% Figure comparaison pour h (face avant)
fig = figure; subplot(2,1,1); hold on;
plot(results_1d1.w, 20*log10(results_1d1.mag{1}), 'b', ...
    LineWidth=1.4, DisplayName="$h="+num2str(h_comp(1))+"$"); 
plot(results_1d2.w, 20*log10(results_1d2.mag{1}), '--r', ...
    LineWidth=1.4, DisplayName="$h="+num2str(h_comp(2))+"$");
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
legend('Location', 'southwest', Interpreter='latex', FontSize=15); 
grid minor; hold off; set(gca, 'XScale', 'log'); subplot(2,1,2); hold on;
plot(results_1d1.w, results_1d1.phase{1}*180/pi, 'b', ...
    LineWidth=1.4); 
plot(results_1d2.w, results_1d2.phase{1}*180/pi, '--r', ...
    LineWidth=1.4); 
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); hold off; grid minor;
saveas(fig, figDir + "\" + analysisName + "\compaire_h1d.eps", 'epsc');
sgtitle("Fonction $F_b(s)$ th\'{e}orique en 1D",'Interpreter','latex', ...
    Interpreter='latex', FontSize=20);

%% Figure pour differentes ordres d'approximation de Pade en 1D

disp("Aproximation de Pade en 1D.");
results_1d_th = model_1d(expData, h); % Résultat théorique

% Modèle pour la face arrière
fig = figure;
for i=1:length(orders)
    results_1d = model_1d_pade(expData, h, orders(i));
    subplot(2,1,1);
    semilogx(results_1d.w, 20*log10(results_1d.mag{1}), colors(i), ...
        LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_1d.w, results_1d.phase{1}*180/pi, colors(i), ...
        LineWidth=1.4);
end
semilogx(results_1d_th.w, results_1d_th.phase{1}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
semilogx(results_1d_th.w, 20*log10(results_1d_th.mag{1}), 'k', ...
    LineWidth=1.4, DisplayName="Th\'{e}orique");  
leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersPade_1d.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Pade en 1D"}, ...
    Interpreter='latex', FontSize=20);

% Modèle pour la face avant
fig = figure;
for i=1:length(orders)
    results_1d = model_1d_pade(expData, h, orders(i));
    subplot(2,1,1);
    semilogx(results_1d.w, 20*log10(results_1d.mag{2}), colors(i), ...
        LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_1d.w, results_1d.phase{2}*180/pi, colors(i), ...
        LineWidth=1.4);
end
semilogx(results_1d_th.w, results_1d_th.phase{2}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
semilogx(results_1d_th.w, 20*log10(results_1d_th.mag{2}), 'k', ...
    LineWidth=1.4, DisplayName="Th\'{e}orique");  
leg = legend(Location='northeast', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersPade_1d.eps", 'epsc');
sgtitle({"Fonction $F_f(s)$ avec", "l'approximation de Pade en 1D"}, ...
    Interpreter='latex', FontSize=20);

%% Figure pour differentes ordres d'approximation de Taylor en 1D
% La comparaison théorique est la même utilisée pour Pade.

disp("Aproximation de Taylor en 1D.");

% Modèle pour la face arrière
fig = figure;
for i=1:length(orders)
    results_1d = model_1d_taylor(expData, h, orders(i));
    subplot(2,1,1);
    semilogx(results_1d.w, 20*log10(results_1d.mag{1}), colors(i), ...
        LineWidth=1.4, DisplayName="$M="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_1d.w, results_1d.phase{1}*180/pi, colors(i), ...
        LineWidth=1.4);
end
semilogx(results_1d_th.w, results_1d_th.phase{1}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
semilogx(results_1d_th.w, 20*log10(results_1d_th.mag{1}), 'k', ...
    LineWidth=1.4, DisplayName="Th\'{e}orique");  
leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_1d.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Taylor en 1D"}, ...
    Interpreter='latex', FontSize=20);

% Modèle pour la face avant
fig = figure;
for i=1:length(orders)
    results_1d = model_1d_taylor(expData, h, orders(i));
    subplot(2,1,1);
    semilogx(results_1d.w, 20*log10(results_1d.mag{2}), colors(i), ...
        LineWidth=1.4, DisplayName="$M="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_1d.w, results_1d.phase{2}*180/pi, colors(i), ...
        LineWidth=1.4);
end
semilogx(results_1d_th.w, results_1d_th.phase{2}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)",'Interpreter','latex','FontSize',15);
xlabel("Fr\'{e}quence (rad/s)",'Interpreter','latex','FontSize',15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
semilogx(results_1d_th.w, 20*log10(results_1d_th.mag{2}), 'k', ...
    LineWidth=1.4, DisplayName="Th\'{e}orique");  
leg = legend(Location='northeast', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Module (dB)",'Interpreter','latex','FontSize',15);
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_1d.eps", 'epsc');
sgtitle({"Fonction $F_f(s)$ avec", "l'approximation de Taylor en 1D"}, ...
    Interpreter='latex', FontSize=20);

%% Analyse 3D/2D (avec une comparaison avec le modèle 1D)
% S'il y a l'axismetrie, il utilisera une analyse 2D en coordonnée cylindrique
% et s'il n'y a pas, il utilisera l'analyse 3D en coordonnée cartesienne.
% La comparaison théorique est la même utilisée pour Pade.

disp("Analyse multidimentional (comparaison).");
results_1d = model_1d(expData, h);
results_multi = model_multi(expData, h*ones(1, 5), 6);

% Figure comparaison 1D/2D/3D
fig = figure; subplot(2,1,1); hold on;
plot(results_1d.w, 20*log10(results_1d.mag{1}), 'b', LineWidth=1.4, ...
    DisplayName="Mod\'{e}le 1D"); 
plot(results_multi.w, 20*log10(results_multi.mag{1}), '--r', LineWidth=1.4,...
    DisplayName="Mod\'{e}le " + type);
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
legend(Location='southwest', Interpreter='latex', FontSize=15); 
grid minor; hold off; set(gca, 'XScale', 'log'); subplot(2,1,2); hold on;
plot(results_1d.w, results_1d.phase{1}*180/pi, 'b', LineWidth=1.4); 
plot(results_multi.w, results_multi.phase{1}*180/pi, '--r', LineWidth=1.4); 
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Fr\'{e}quence (rad/s)",Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); hold off; grid minor;
saveas(fig, figDir + "\" + analysisName + "\compaire_h3d.eps", 'epsc');
sgtitle({"Comparaison de $F_b(s)$ entre les", "mod\'{e}les 1D et " + type}, ...
    Interpreter='latex', FontSize=20);

%% Figure pour differentes ordres d'approximation de Pade en 3D/2D
% S'il y a l'axismetrie, il utilisera une analyse 2D en coordonnée cylindrique
% et s'il n'y a pas, il utilisera l'analyse 3D en coordonnée cartesienne.
% La comparaison théorique est la même utilisée pour Pade.

disp("Aproximation de Pade pour l'analyse 2D/3D.");

% Modèle pour la face arrière
fig = figure;
for i=1:length(orders)
    results_multi_pade = model_multi_pade(expData, h*ones(1, 5), orders(i), 6);

    subplot(2,1,1);
    semilogx(results_multi_pade.w, 20*log10(results_multi_pade.mag{1}), ...
        colors(i),LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_multi_pade.w, results_multi_pade.phase{1}*180/pi, ...
        colors(i), LineWidth=1.4);
end
semilogx(results_multi.w, results_multi.phase{1}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
semilogx(results_multi.w, 20*log10(results_multi.mag{1}), 'k', ...
    LineWidth=1.4, DisplayName="Th\'{e}orique");  
leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersPade_3d.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Pade en " + type}, ...
    Interpreter='latex', FontSize=20);

% Modèle pour la face avant
fig = figure;
for i=1:length(orders)
    results_multi_pade = model_multi_pade(expData, h*ones(1, 5), orders(i), 6);

    subplot(2,1,1);
    semilogx(results_multi_pade.w, 20*log10(results_multi_pade.mag{2}), ...
        colors(i),LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_multi_pade.w, results_multi_pade.phase{2}*180/pi, ...
        colors(i), LineWidth=1.4);
end
semilogx(results_multi.w, results_multi.phase{2}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
semilogx(results_multi.w, 20*log10(results_multi.mag{2}), 'k', ...
    LineWidth=1.4, DisplayName="Th\'{e}orique");  
leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersPade_3d.eps", 'epsc');
sgtitle({"Fonction $F_f(s)$ avec", "l'approximation de Pade en " + type}, ...
    Interpreter='latex', FontSize=20);

%% Figure pour differentes ordres d'approximation de Taylor en 3D/2D
% S'il y a l'axismetrie, il utilisera une analyse 2D en coordonnée cylindrique
% et s'il n'y a pas, il utilisera l'analyse 3D en coordonnée cartesienne.
% La comparaison théorique est la même utilisée pour Pade.

disp("Aproximation de Taylor pour l'analyse 2D/3D.");

% Modèle pour la face arrière
fig = figure;
for i=1:length(orders)
    results_multi_taylor = model_multi_taylor(expData, h*ones(1, 5), orders(i), 6);

    subplot(2,1,1);
    semilogx(results_multi_taylor.w, 20*log10(results_multi_taylor.mag{1}),...
        colors(i),LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_multi_taylor.w, results_multi_taylor.phase{1}*180/pi,...
        colors(i), LineWidth=1.4);
end
semilogx(results_multi.w, results_multi.phase{1}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)",'Interpreter','latex','FontSize',15);
xlabel("Fr\'{e}quence (rad/s)",'Interpreter','latex','FontSize',15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
semilogx(results_multi.w, 20*log10(results_multi.mag{1}), 'k', ...
    LineWidth=1.4, DisplayName="Th\'{e}orique");  
leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Module (dB)",'Interpreter','latex','FontSize',15);
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_3d.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Taylor en " + type}, ...
    'Interpreter','latex', 'FontSize', 20);

% Modèle pour la face avant
fig = figure;
for i=1:length(orders)    
    results_multi_taylor = model_multi_taylor(expData, h*ones(1, 5), orders(i), 6);

    subplot(2,1,1);
    semilogx(results_multi_taylor.w, 20*log10(results_multi_taylor.mag{2}),...
        colors(i),LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_multi_taylor.w, results_multi_taylor.phase{2}*180/pi,...
        colors(i), LineWidth=1.4);
end
semilogx(results_multi.w, results_multi.phase{2}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)",'Interpreter','latex','FontSize',15);
xlabel("Fr\'{e}quence (rad/s)",'Interpreter','latex','FontSize',15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
semilogx(results_multi.w, 20*log10(results_multi.mag{2}), 'k', ...
    LineWidth=1.4, DisplayName="Th\'{e}orique");  
leg = legend(Location='northeast', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Module (dB)",'Interpreter','latex','FontSize',15);
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_3d.eps", 'epsc');
sgtitle({"Fonction $F_f(s)$ avec", "l'approximation de Taylor en " + type}, ...
    'Interpreter','latex', 'FontSize', 20);

%% Fin de l'analyse
msg = 'Appuyez pour continuer...';
input(msg);
fprintf(repmat('\b', 1, length(msg)+1)+"\n");
close all;
