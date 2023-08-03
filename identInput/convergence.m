function models = convergence(dataIn, maxOrder, delayOrders, varargin)
    %% CONVERGENCE
    %
    % Fonction faite pour vérifier la convergence des modèles analysés. La
    % fonction utilise quatre modéles polynomials différentes : les modèles
    % OE, ARX, ARMAX et BJ. La sortie models est une struct avec les
    % informations des modèles.
    %
    % ENTRÉES :
    %
    %   - dataIn : variable iddata avec l'entrée qui va être simulée. Les
    %   information des coefficients thermiques du material et les autres
    %   carachteristiques comme la masse volumique sont estoquées dans le
    %   champs UserData dedans dataIn. Il sera estoqué comme sysDataType.
    %
    %   - maxOrder : define l'ordre maximale pour la vérification de la
    %   convergence.
    %
    %   - delayOrders : informe l'ordre du retar dans l'analyse. Si il est
    %   un scalaire, la analyse sera faite pour nk = delayOrders. Si il est
    %   un vecteur, l'analyse sera faite pour nk = 1:delayOrders,
    %   length(delayOrders) analyses en total.
    %
    % EXAMPLE D'APPELL :
    %
    %   compare_results(dataIn, maxOrder, delayOrders)) : prendre l'analyse
    %   de convergence pour le retard specifié en delayOrders jusqu'à ordre
    %   definie en maxOrders
    %
    %   compare_results(__, options) : pour données des autres options à
    %   l'analyse.
    %
    % OPTIONS :
    %   
    %   minOrder : ordre minimale pour laquelle l'analyse de convergence va
    %   être faite. Par défault minOrder = 1.
    %
    % See also arx, oe, armax, bj, iddata.

    %% Entrées
    
    % Paramètres de la simulation
    figDir = 'outFig';                     % [-] Dossier pour les figures ;
    colors = ['r','g','b','y'];            % [-] Couleurs des graphiques ;
    linSty = ["-"; "--"; "-."; ":"];       % [-] Type de trace ;

    % Entrées defaults
    minOrder = 1;
    
    % Prendre les entrées optionnelles
    if ~isempty(varargin)
        for arg = 1:length(varargin)
            switch varargin{arg,1}
                case ("minOrder")
                    if minOrder < maxOrder
                        minOrder = varargin{arg, 2};
                    else
                        error("La valeur de l'ordre minimale doit être"+...
                            "plus petite que celui pour l'ordre" + ...
                            "maximale.");
                    end
                    break;                    
            end
        end
    end
    
    %% Preparation de données et fichiers

    analysisName = dataIn.UserData.name;
    if not(isfolder(figDir + "\" + analysisName))
        mkdir(figDir + "\" + analysisName);
    end
    
    % Paramètres des modèles (simulation au lieu de la prediction)
    arxOpt = arxOptions('Focus', 'simulation');
    armaxOpt = armaxOptions('Focus', 'simulation');
    bjOpt = bjOptions('Focus', 'simulation');
    
    % Initialization des variables
    J_oe = zeros(maxOrder-minOrder+1, 3);
    J_arx = zeros(maxOrder-minOrder+1, 3);
    J_armax = zeros(maxOrder-minOrder+1, 3);
    J_bj = zeros(maxOrder-minOrder+1, 3);
    
    %% Convergence d'ordre des modèles
    
    figLossFunc = figure;
    figFPE = figure;
    figAIC = figure;
    
    for i = 1:length(delayOrders)

        fprintf("\tAnalyse pour le retard nk = %d.\n", delayOrders(i));
        fprintf("\t\tAnalyse en 00%%.");
        for order = minOrder:maxOrder
    
            % Modèle ARX
            sysARX = arx(dataIn, [order, order+1, delayOrders(i)], arxOpt);
            J_arx(order-minOrder+1, 1) = mag2db(sysARX.report.Fit.LossFcn);
            J_arx(order-minOrder+1, 2) = sysARX.report.Fit.FPE;  
            J_arx(order-minOrder+1, 3) = sysARX.report.Fit.AIC; 
    
            % Initialisation de la optimization (non linéaire)
            if order == minOrder
                sys_init_oe = idpoly(1, sysARX.B, 1, 1, sysARX.A, ...
                    sysARX.NoiseVariance, sysARX.Ts);
                sys_init_armax = idpoly(1, sysARX.B, [1 0], 1, sysARX.A, ...
                    sysARX.NoiseVariance, sysARX.Ts);
                sys_init_bj = idpoly(1, sysARX.B, [1 0], [1 0], ...
                    sysARX.A, sysARX.NoiseVariance, sysARX.Ts);
            else
                sys_init_oe = idpoly(1, [sysOE.B 0], 1, 1, [sysOE.F 0], ...
                    sysOE.NoiseVariance, sysOE.Ts);
                sys_init_armax = idpoly([sysARMAX.A 0], [sysARMAX.B 0], ...
                    [sysARMAX.C 0],1,1,sysARMAX.NoiseVariance,sysARMAX.Ts);
                sys_init_bj = idpoly(1, [sysBJ.B 0], [sysBJ.C 0], ...
                    [sysBJ.D 0],[sysBJ.F 0],sysBJ.NoiseVariance, sysBJ.Ts);
            end
    
            % Modèle OE
            sys_init_oe.TimeUnit = 'milliseconds';
            sysOE = oe(dataIn, sys_init_oe);
            J_oe(order-minOrder+1, 1) = 20*log10(sysOE.report.Fit.LossFcn);
            J_oe(order-minOrder+1, 2) = sysOE.report.Fit.FPE;  
            J_oe(order-minOrder+1, 3) = sysOE.report.Fit.AIC; 
    
            % Modèle ARMAX
            sys_init_armax.TimeUnit = 'milliseconds';
            sysARMAX = armax(dataIn, sys_init_armax, armaxOpt);
            J_armax(order-minOrder+1, 1) = ...
                mag2db(sysARMAX.report.Fit.LossFcn);
            J_armax(order-minOrder+1, 2) = sysARMAX.report.Fit.FPE;
            J_armax(order-minOrder+1, 3) = sysARMAX.report.Fit.AIC;
    
            % Modèle BJ
            sys_init_bj.TimeUnit = 'milliseconds';
            sysBJ = bj(dataIn, sys_init_bj, bjOpt);
            J_bj(order-minOrder+1, 1) = mag2db(sysBJ.report.Fit.LossFcn);
            J_bj(order-minOrder+1, 2) = sysBJ.report.Fit.FPE;
            J_bj(order-minOrder+1, 3) = sysBJ.report.Fit.AIC;

            % Affiche le progrèss
            p = 100*(order - minOrder)/(maxOrder - minOrder);
            fprintf("\b\b\b\b%02.0f%%.", p);
        end

        fprintf("\n\t\tAffichage et enregistrement des figures.\n");
        % Critère d'erreur
        figure(figLossFunc);
        subplot(4, 1, 1);  hold on;
        plot(minOrder:maxOrder,  J_oe(:, 1), colors(i), ...
            LineStyle=linSty(i), LineWidth=1.4, DisplayName="$n_k = " + ...
            num2str(delayOrders(i))+"$");
        subplot(4, 1, 2);  hold on;
        plot(minOrder:maxOrder, J_arx(:, 1), colors(i), ...
            LineStyle=linSty(i), LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 3);  hold on;
        plot(minOrder:maxOrder, J_armax(:, 1), colors(i), ...
            LineStyle=linSty(i), LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 4);  hold on;
        plot(minOrder:maxOrder, J_bj(:, 1), colors(i), ...
            LineStyle=linSty(i), LineWidth=1.4, HandleVisibility='off');
    
        % Critère FPE
        figure(figFPE);
        subplot(4, 1, 1);  hold on;
        plot(minOrder:maxOrder,  J_oe(:, 2), colors(i), ...
            LineStyle=linSty(i), LineWidth=1.4, DisplayName="$n_k = " + ...
            num2str(delayOrders(i))+"$");
        subplot(4, 1, 2);  hold on;
        plot(minOrder:maxOrder, J_arx(:, 2), colors(i), ...
            LineStyle=linSty(i), LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 3);  hold on;
        plot(minOrder:maxOrder, J_armax(:, 2), colors(i), ...
            LineStyle=linSty(i), LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 4);  hold on;
        plot(minOrder:maxOrder, J_bj(:, 2), colors(i), ...
            LineStyle=linSty(i), LineWidth=1.4, HandleVisibility='off');
    
        % Critère AIC
        figure(figAIC);
        subplot(4, 1, 1);  hold on;
        plot(minOrder:maxOrder,  J_oe(:, 3), colors(i), ...LineStyle=linSty(i), ...
            LineWidth=1.4, DisplayName="$n_k = " + ...
            num2str(delayOrders(i))+"$");
        subplot(4, 1, 2);  hold on;
        plot(minOrder:maxOrder, J_arx(:, 3), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 3);  hold on;
        plot(minOrder:maxOrder, J_armax(:, 3), colors(i), LineStyle=linSty(i), ...
            LineWidth=1.4, HandleVisibility='off');
        subplot(4, 1, 4);  hold on;
        plot(minOrder:maxOrder, J_bj(:, 3), colors(i), LineStyle=linSty(i), ...
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
    figLossFunc.Position = [610 253 810 644];
    saveas(figLossFunc, figDir + "\" + analysisName + ...
        "\orderIdent_polyLossFunc.eps");
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
    figFPE.Position = [610 253 810 644];
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
    figAIC.Position = [610 253 810 644];
    saveas(figAIC, figDir+"\"+analysisName+"\orderIdent_polyAIC.eps");
    sgtitle("Analyse de convergence pour l'erreur AIC", ...
        Interpreter="latex", FontSize=20);

    %% Résultat
    models.ARX = sysARX;
    models.ARMAX = sysARMAX;
    models.BJ = sysBJ;
    models.OE = sysOE;
end