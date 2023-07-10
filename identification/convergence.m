function convergence(dataIn, maxOrder, delayOrders)
    %% CONVERGENCE
    % Analyse de convergence des modèles par rapport á lordre du modèle.
    % Quatre types de modèles differentes sont analysés : ARX, OE, ARMAX et
    % le modéle BJ.

    %% Entrées
    
    % Paramètres de la simulation
    analysisName = 'sys1_polBas';          % [-] Nom de l'analyse ;
    dataDir = '..\dataBase\convertedData'; % [-] Dossier pour les données ;
    figDir = 'outFig';                     % [-] Dossier pour les figures ;
    colors = ['r','g','b','y'];            % [-] Couleurs des graphiques ;
    linSty = ["-"; "--"; "-."; ":"]; % [-] Type de trace ;
    
    %% Preparation de données et fichiers

    if not(isfolder(figDir + "\" + analysisName))
        mkdir(figDir + "\" + analysisName);
    end
    
    % Paramètres des modèles (simulation au lieu de la prediction)
    arxOpt = arxOptions('Focus', 'simulation');
    armaxOpt = armaxOptions('Focus', 'simulation');
    bjOpt = bjOptions('Focus', 'simulation');
    
    % Initialization des variables
    J_oe = zeros(maxOrder, 3);
    J_arx = zeros(maxOrder, 3);
    J_armax = zeros(maxOrder, 3);
    J_bj = zeros(maxOrder, 3);
    
    %% Convergence d'ordre des modèles
    
    figLossFunc = figure;
    figFPE = figure;
    figAIC = figure;
    
    for i = 1:length(delayOrders)
        for order = 1:maxOrder
    
            % Modèle ARX
            if order == 1
                sysARX = arx(dataIn, [order, order+1, ...
                    delayOrders(i)], arxOpt);
            else
                sys_init_arx = idpoly([sysARX.A 0], [sysARX.B 0],...
                    1, 1, 1, sysARX.NoiseVariance, sysARX.Ts);
                sys_init_arx.TimeUnit = 'milliseconds';
                sysARX = arx(dataIn, sys_init_arx, arxOpt);
            end
            J_arx(order, 1) = 20*log10(sysARX.report.Fit.LossFcn);
            J_arx(order, 2) = sysARX.report.Fit.FPE;  
            J_arx(order, 3) = sysARX.report.Fit.AIC; 
    
            % Initialisation de la optimization (non linéaire)
            if order == 1
                sys_init_oe = idpoly(1, sysARX.B, 1, 1, sysARX.A, ...
                    sysARX.NoiseVariance, sysARX.Ts);
                sys_init_armax = idpoly(1, sysARX.B, [1 0], 1, sysARX.A, ...
                    sysARX.NoiseVariance, sysARX.Ts);
                sys_init_bj = idpoly(1, sysARX.B, [1 0], [1 0], sysARX.A, ...
                    sysARX.NoiseVariance, sysARX.Ts);
            else
                sys_init_oe = idpoly(1, [sysOE.B 0], 1, 1, [sysOE.F 0], ...
                    sysOE.NoiseVariance, sysOE.Ts);
                sys_init_armax = idpoly([sysARMAX.A 0], [sysARMAX.B 0], ...
                    [sysARMAX.C 0], 1, 1, sysARMAX.NoiseVariance, sysARMAX.Ts);
                sys_init_bj = idpoly(1, [sysBJ.B 0], [sysBJ.C 0], [sysBJ.D 0], ...
                    [sysBJ.F 0], sysBJ.NoiseVariance, sysBJ.Ts);
            end
    
            % Modèle OE
            sys_init_oe.TimeUnit = 'milliseconds';
            sysOE = oe(dataIn, sys_init_oe);
            J_oe(order, 1) = 20*log10(sysOE.report.Fit.LossFcn);
            J_oe(order, 2) = sysOE.report.Fit.FPE;  
            J_oe(order, 3) = sysOE.report.Fit.AIC; 
    
            % Modèle ARMAX
            sys_init_armax.TimeUnit = 'milliseconds';
            sysARMAX = armax(dataIn, sys_init_armax, armaxOpt);
            J_armax(order, 1) = 20*log10(sysARMAX.report.Fit.LossFcn);
            J_armax(order, 2) = sysARMAX.report.Fit.FPE;
            J_armax(order, 3) = sysARMAX.report.Fit.AIC;
    
            % Modèle BJ
            sys_init_bj.TimeUnit = 'milliseconds';
            sysBJ = bj(dataIn, sys_init_bj, bjOpt);
            J_bj(order, 1) = 20*log10(sysBJ.report.Fit.LossFcn);
            J_bj(order, 2) = sysBJ.report.Fit.FPE;
            J_bj(order, 3) = sysBJ.report.Fit.AIC;
        end
    
        % Critère d'erreur
        figure(figLossFunc);
        subplot(4, 1, 1);  hold on;
        plot(1:maxOrder,  J_oe(:, 1), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, DisplayName="$n_k = "+num2str(delayOrders(i))+"$");
        subplot(4, 1, 2);  hold on;
        plot(1:maxOrder, J_arx(:, 1), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 3);  hold on;
        plot(1:maxOrder, J_armax(:, 1), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 4);  hold on;
        plot(1:maxOrder, J_bj(:, 1), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
    
        % Critère FPE
        figure(figFPE);
        subplot(4, 1, 1);  hold on;
        plot(1:maxOrder,  J_oe(:, 2), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, DisplayName="$n_k = "+num2str(delayOrders(i))+"$");
        subplot(4, 1, 2);  hold on;
        plot(1:maxOrder, J_arx(:, 2), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 3);  hold on;
        plot(1:maxOrder, J_armax(:, 2), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 4);  hold on;
        plot(1:maxOrder, J_bj(:, 2), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
    
        % Critère AIC
        figure(figAIC);
        subplot(4, 1, 1);  hold on;
        plot(1:maxOrder,  J_oe(:, 3), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, DisplayName="$n_k = "+num2str(delayOrders(i))+"$");
        subplot(4, 1, 2);  hold on;
        plot(1:maxOrder, J_arx(:, 3), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 3);  hold on;
        plot(1:maxOrder, J_armax(:, 3), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 4);  hold on;
        plot(1:maxOrder, J_bj(:, 3), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
    end
    
    % Figure pour l'erreur d'équation (configurations graphiques finales)
    figure(figLossFunc);
    subplot(4, 1, 1);  hold off; grid minor;
    legend(Interpreter="latex", FontSize=17, Location="best");
    ylabel({"Mod\`{e}le", "OE"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 2);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "ARX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 3);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "ARMAX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 4);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "BJ"}, Interpreter="latex", FontSize=17);
    xlabel("Ordre $n_a = n_b$", Interpreter="latex", FontSize=17);
    %fig.Position = [558 258 815 582];
    figLossFunc.Position = [305 52 759 615];
    saveas(figLossFunc,figDir+"\"+analysisName+"\orderIdent_polyLossFunc.eps");
    sgtitle("Analyse de convergence pour l'erreur d'\'{e}quation", ...
        Interpreter="latex", FontSize=20);
    
    % Figure pour l'erreur FPE (configurations graphiques finales)
    figure(figFPE)
    subplot(4, 1, 1);  hold off; grid minor;
    legend(Interpreter="latex", FontSize=17, Location="best");
    ylabel({"Mod\`{e}le", "OE"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 2);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "ARX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 3);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "ARMAX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 4);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "BJ"}, Interpreter="latex", FontSize=17);
    xlabel("Ordre $n_a = n_b$", Interpreter="latex", FontSize=17);
    %fig.Position = [558 258 815 582];
    figFPE.Position = [305 52 759 615];
    saveas(figFPE, figDir+"\"+analysisName+"\orderIdent_polyFPE.eps");
    sgtitle("Analyse de convergence pour l'erreur FPE", ...
        Interpreter="latex", FontSize=20);
    
    % Figure pour l'erreur AIC (configurations graphiques finales)
    figure(figAIC);
    subplot(4, 1, 1);  hold off; grid minor;
    legend(Interpreter="latex", FontSize=17, Location="best");
    ylabel({"Mod\`{e}le", "OE"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 2);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "ARX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 3);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "ARMAX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 4);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "BJ"}, Interpreter="latex", FontSize=17);
    xlabel("Ordre $n_a = n_b$", Interpreter="latex", FontSize=17);
    %fig.Position = [558 258 815 582];
    figAIC.Position = [305 52 759 615];
    saveas(figAIC, figDir+"\"+analysisName+"\orderIdent_polyAIC.eps");
    sgtitle("Analyse de convergence pour l'erreur AIC", ...
        Interpreter="latex", FontSize=20);