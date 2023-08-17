clear; close all;
%% Inputs and definitions
figDir = 'outFig';            % Directory for output figures
analysisName = 'sys1_isoBas'; % Analysis name
expNumber = 1;                % Number for the experiment to be used
orders = [1 6 10];            % Orders for Pade an Taylor approximations
colors = ['r','b','g','m'];   % Graph colors
h_comp = [7, 25];             % Values for h (compare)
h = 17;                       % Final value for h
Ts = 100e-3;                  % [s] Time sampling (discretization of tf)

fprintf("<strong>Frequency analysis</strong>\n");

%% Output directory verification and multidimentional analysis
if not(isfolder(figDir + "\" + analysisName))
    mkdir(figDir + "\" + analysisName);
end

disp("Loading variables.");
addpath('..\database'); % For the class definitions
load("..\database\convertedData\" + analysisName + ".mat");

% Choos the multidimenstional analysis to be used
if strcmp(expData.sysData.Geometry, "Cylinder") % 2D
    model_multi = @(var1, var2, var3) model_2d(var1, var2, var3);
    model_multi_pade = @(var1, var2, var3, var4) model_2d_pade(var1, ...
        var2, var3, var4);
    model_multi_taylor = @(var1, var2, var3, var4) model_2d_taylor(var1,...
        var2,var3, var4);
    type = "2D";
elseif strcmp(expData.sysData.Geometry, "Cube") % 3D
    model_multi = @(var1, var2, var3) model_3d(var1, var2, var3);
    model_multi_pade = @(var1, var2, var3, var4) model_3d_pade(var1, ...
        var2, var3, var4);
    model_multi_taylor = @(var1, var2, var3, var4) model_3d_taylor(var1,...
        var2, var3, var4);
    type = "3D";
else
    error("Field << Geometry >> is not valid.");
end

%% 1D analysis (with the comparison between h values)

disp("One-dimentional analysis for different h values.");

results_1d1 = model_1d(expData, h_comp(1));
results_1d2 = model_1d(expData, h_comp(2));

% Figure in english
fig = figure; subplot(2,1,1); hold on;
plot(results_1d1.w, 20*log10(results_1d1.mag{1}), 'b', ...
    LineWidth=1.4, DisplayName="$h="+num2str(h_comp(1))+"$"); 
plot(results_1d2.w, 20*log10(results_1d2.mag{1}), '--r', ...
    LineWidth=1.4, DisplayName="$h="+num2str(h_comp(2))+"$");
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
legend('Location', 'southwest', Interpreter='latex', FontSize=15); 
grid minor; hold off; set(gca, 'XScale', 'log'); subplot(2,1,2); hold on;
plot(results_1d1.w, results_1d1.phase{1}*180/pi, 'b', ...
    LineWidth=1.4); 
plot(results_1d2.w, results_1d2.phase{1}*180/pi, '--r', ...
    LineWidth=1.4); 
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); hold off; grid minor;
saveas(fig, figDir + "\" + analysisName + "\compaire_h1d_en.eps", 'epsc');

% Figure in french
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
subplot(2,1,1); grid minor;
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); hold off; grid minor;
saveas(fig, figDir + "\" + analysisName + "\compaire_h1d_fr.eps", 'epsc');
sgtitle("Fonction $F_b(s)$ th\'{e}orique en 1D",'Interpreter','latex', ...
    Interpreter='latex', FontSize=20);

%% Pade approximation orders figure

disp("Pade approximation in 1D.");
results_1d_th = model_1d(expData, h); % Theorical result

% Rear face model (english)
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
xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
thPlot = semilogx(results_1d_th.w, 20*log10(results_1d_th.mag{1}), 'k', ...
    LineWidth=1.4, DisplayName="Theorical");  
leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersPade_1d_back_en.eps", 'epsc');

% Rear face model (french)
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
subplot(2,1,2);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(thPlot, 'displayName', "Th\'{e}orique");
saveas(fig, figDir + "\" + analysisName + "\ordersPade_1d_back_fr.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Pade en 1D"}, ...
    Interpreter='latex', FontSize=20);

% Front face model (english)
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
xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
thPlot = semilogx(results_1d_th.w, 20*log10(results_1d_th.mag{2}), 'k', ...
    LineWidth=1.4, DisplayName="Theorical");  
leg = legend(Location='northeast', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersPade_1d_front_en.eps", 'epsc');

% Front face model (french)
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
subplot(2,1,2);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(thPlot, 'displayName', "Th\'{e}orique");
saveas(fig, figDir + "\" + analysisName + "\ordersPade_1d_front_fr.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Pade en 1D"}, ...
    Interpreter='latex', FontSize=20);

%% Taylor approximation orders figure

disp("Taylor approximation in 1D.");
results_1d_th = model_1d(expData, h); % Theorical result

% Rear face model (english)
fig = figure;
for i=1:length(orders)
    results_1d = model_1d_taylor(expData, h, orders(i));
    subplot(2,1,1);
    semilogx(results_1d.w, 20*log10(results_1d.mag{1}), colors(i), ...
        LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_1d.w, results_1d.phase{1}*180/pi, colors(i), ...
        LineWidth=1.4);
end
semilogx(results_1d_th.w, results_1d_th.phase{1}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
thPlot = semilogx(results_1d_th.w, 20*log10(results_1d_th.mag{1}), 'k', ...
    LineWidth=1.4, DisplayName="Theorical");  
leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_1d_back_en.eps", 'epsc');

% Rear face model (french)
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
subplot(2,1,2);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(thPlot, 'displayName', "Th\'{e}orique");
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_1d_back_fr.eps", 'epsc');
sgtitle({"Fonction $F_f(s)$ avec", "l'approximation de Taylor en 1D"}, ...
    Interpreter='latex', FontSize=20);

% Front face model (english)
fig = figure;
for i=1:length(orders)
    results_1d = model_1d_taylor(expData, h, orders(i));
    subplot(2,1,1);
    semilogx(results_1d.w, 20*log10(results_1d.mag{2}), colors(i), ...
        LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_1d.w, results_1d.phase{2}*180/pi, colors(i), ...
        LineWidth=1.4);
end
semilogx(results_1d_th.w, results_1d_th.phase{2}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
thPlot = semilogx(results_1d_th.w, 20*log10(results_1d_th.mag{2}), 'k', ...
    LineWidth=1.4, DisplayName="Theorical");  
leg = legend(Location='northeast', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_1d_front_en.eps", 'epsc');

% Front face model (french)
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
subplot(2,1,2);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(thPlot, 'displayName', "Th\'{e}orique");
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_1d_front_fr.eps", 'epsc');
sgtitle({"Fonction $F_f(s)$ avec", "l'approximation de Taylor en 1D"}, ...
    Interpreter='latex', FontSize=20);

%% Comparison between Taylor and Pade (rear face)

disp("Comparison between Taylor and Pade.");

results_1d_th = model_1d(expData, h); % Theorical result
results_1d1 = model_1d_taylor(expData, h);
results_1d2 = model_1d_pade(expData, h);

% Figure in english
fig = figure; subplot(2,1,1); hold on;
plot(results_1d1.w, 20*log10(results_1d1.mag{1}), 'b', ...
    LineWidth=1.4, DisplayName="Taylor"); 
plot(results_1d2.w, 20*log10(results_1d2.mag{1}), '--r', ...
    LineWidth=1.4, DisplayName="Pad\'{e}");
thPlot = plot(results_1d_th.w, 20*log10(results_1d_th.mag{1}), 'k', ...
    LineWidth=1.4, DisplayName="Theorical"); 
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
legend('Location', 'southwest', Interpreter='latex', FontSize=15); 
grid minor; hold off; set(gca, 'XScale', 'log'); subplot(2,1,2); hold on;
plot(results_1d1.w, results_1d1.phase{1}*180/pi, 'b', LineWidth=1.4); 
plot(results_1d2.w, results_1d2.phase{1}*180/pi, '--r', LineWidth=1.4); 
plot(results_1d_th.w, results_1d_th.phase{1}*180/pi, 'k', LineWidth=1.4); 
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); hold off; grid minor;
saveas(fig, figDir + "\" + analysisName + "\compaire_taylorpade_en.eps", 'epsc');

% Figure in french
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
subplot(2,1,1); grid minor;
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); hold off; grid minor;
set(thPlot, 'displayName', "Th\'{e}orique");
saveas(fig, figDir + "\" + analysisName + "\compaire_taylorpade_fr.eps", 'epsc');
sgtitle("Fonction $F_b(s)$ th\'{e}orique en 1D",'Interpreter','latex', ...
    Interpreter='latex', FontSize=20);

%% 2D/3D analysis (comparison with 1D)
% If the system is axisymetric, it will use a 2D analysis in cylindric
% coorenates. If it is not, it will use a 3D analysis in regular cartesian
% coordenates.

disp("Multidimentional analysis (comparison).");
results_1d = model_1d(expData, h);
results_multi = model_multi(expData, h*ones(1, 5), 6);

% Figure comparison 1D/2D/3D (english)
fig = figure; subplot(2,1,1); hold on;
th1Plot = plot(results_1d.w, 20*log10(results_1d.mag{1}), 'b', ...
    LineWidth=1.4, DisplayName="Model 1D"); 
th2Plot = plot(results_multi.w, 20*log10(results_multi.mag{1}), '--r', ...
    LineWidth=1.4, DisplayName="Model " + type);
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
legend(Location='southwest', Interpreter='latex', FontSize=15); 
grid minor; hold off; set(gca, 'XScale', 'log'); subplot(2,1,2); hold on;
plot(results_1d.w, results_1d.phase{1}*180/pi, 'b', LineWidth=1.4); 
plot(results_multi.w, results_multi.phase{1}*180/pi, '--r', LineWidth=1.4); 
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Frequency (rad/s)",Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); hold off; grid minor;
saveas(fig, figDir + "\" + analysisName + "\compaire_3d_en.eps", 'epsc');

% Figure comparison 1D/2D/3D (french)
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
subplot(2,1,2);
set(th1Plot, 'displayName', "Mod\'{e}le 1D");
set(th2Plot, 'displayName', "Mod\'{e}le " + type);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\compaire_3d_fr.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Taylor en 1D"}, ...
    Interpreter='latex', FontSize=20);

%% Figure for Pade approximation in 2D/3D
% If the system is axisymetric, it will use a 2D analysis in cylindric
% coorenates. If it is not, it will use a 3D analysis in regular cartesian
% coordenates. The approximation is the same used in 1D.

disp("Pade approximation for 2D/3D analysis.");

% Rear face model (english)
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
xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
thPlot = semilogx(results_multi.w, 20*log10(results_multi.mag{1}), 'k', ...
    LineWidth=1.4, DisplayName="Theorical");  
leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersPade_3d_rear_en.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Pade en " + type}, ...
    Interpreter='latex', FontSize=20);

% Rear face model (french)
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
subplot(2,1,2);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(thPlot, 'displayName', "Th\'{e}orique");
saveas(fig, figDir + "\" + analysisName + "\ordersPade_3d_rear_fr.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Pade en" + type}, ...
    Interpreter='latex', FontSize=20);

% Front face model (english)
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
xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
thPlot = semilogx(results_multi.w, 20*log10(results_multi.mag{2}), 'k', ...
    LineWidth=1.4, DisplayName="Theorical");  
leg = legend(Location='northeast', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersPade_3d_front_en.eps", 'epsc');

% Rear face model (french)
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
subplot(2,1,2);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(thPlot, 'displayName', "Th\'{e}orique");
saveas(fig, figDir + "\" + analysisName + "\ordersPade_3d_front_fr.eps", 'epsc');
sgtitle({"Fonction $F_f(s)$ avec", "l'approximation de Pade en" + type}, ...
    Interpreter='latex', FontSize=20);

%% Figure for Taylor approximation in 2D/3D
% If the system is axisymetric, it will use a 2D analysis in cylindric
% coorenates. If it is not, it will use a 3D analysis in regular cartesian
% coordenates. The approximation is the same used in 1D.

disp("Taylor approximation for 2D/3D analysis.");

% Rear face model (english)
fig = figure;
for i=1:length(orders)
    results_multi_taylor = model_multi_taylor(expData, h*ones(1, 5), ...
        orders(i), 6);

    subplot(2,1,1);
    semilogx(results_multi_taylor.w, 20*log10(results_multi_taylor.mag{1}), ...
        colors(i),LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_multi_taylor.w, results_multi_taylor.phase{1}*180/pi, ...
        colors(i), LineWidth=1.4);
end
semilogx(results_multi.w, results_multi.phase{1}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
thPlot = semilogx(results_multi.w, 20*log10(results_multi.mag{1}), 'k', ...
    LineWidth=1.4, DisplayName="Theorical");  
leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_3d_rear_en.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Taylor en " + type}, ...
    Interpreter='latex', FontSize=20);

% Rear face model (french)
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
subplot(2,1,2);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(thPlot, 'displayName', "Th\'{e}orique");
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_3d_rear_fr.eps", 'epsc');
sgtitle({"Fonction $F_b(s)$ avec", "l'approximation de Taylor en" + type}, ...
    Interpreter='latex', FontSize=20);

% Front face model (english)
fig = figure;
for i=1:length(orders)
    results_multi_taylor = model_multi_taylor(expData, h*ones(1, 5), ...
        orders(i), 6);

    subplot(2,1,1);
    semilogx(results_multi_taylor.w, 20*log10(results_multi_taylor.mag{2}), ...
        colors(i),LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
    hold on; subplot(2,1,2); hold on;
    semilogx(results_multi_taylor.w, results_multi_taylor.phase{2}*180/pi, ...
        colors(i), LineWidth=1.4);
end
semilogx(results_multi.w, results_multi.phase{2}*180/pi, 'k', LineWidth=1.4);
ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
set(gca, 'XScale', 'log'); grid minor;
subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
thPlot = semilogx(results_multi.w, 20*log10(results_multi.mag{2}), 'k', ...
    LineWidth=1.4, DisplayName="Theorical");  
leg = legend(Location='northeast', Interpreter='latex', FontSize=15, ...
    NumColumns=2); 
leg.ItemTokenSize = [20, 18];
ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_3d_front_en.eps", 'epsc');

% Rear face model (french)
ylabel("Module (dB)", Interpreter='latex', FontSize=15);
subplot(2,1,2);
xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
set(thPlot, 'displayName', "Th\'{e}orique");
saveas(fig, figDir + "\" + analysisName + "\ordersTaylor_3d_front_fr.eps", 'epsc');
sgtitle({"Fonction $F_f(s)$ avec", "l'approximation de Taylor en" + type}, ...
    Interpreter='latex', FontSize=20);

%% Write some data to tables (latex)

table2tex(expData);

% Taylor 1D
[~, Fs_taylor_1d] = model_1d_taylor(expData, h, 6);
tf2tex(Fs_taylor_1d{1}, "\\widetilde{G}_\\phi(s)", 'G_1d_taylor_cont');
tf2tex(c2d(Fs_taylor_1d{1}, Ts, 'zoh'), "\\widetilde{G}_\\phi(s)", ...
    'G_1d_taylor_disc');


%% Fin de l'analyse
msg = 'Press any key to continue...';
input(msg);
fprintf(repmat('\b', 1, length(msg)+1)+"\n");
close all;
