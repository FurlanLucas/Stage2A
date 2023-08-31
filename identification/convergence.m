function models = convergence(dataIn, maxOrder, delayOrders, varargin)
    %% convergence
    %
    % Function that verifies the model convergence for each noise structure
    % choosen: OE, ARX, ARMAX et BJ. The output is a structure with the
    % idpolys for each model.
    %
    % Calls
    %   
    %   models = convergence(dataIn, maxOrder, delayOrders): take the
    %   models with the best convergence in the analysis for a maximum
    %   order of maxOrder and for the delayOrders specified.
    %
    %   models = convergence(__, options): take the optional arguments.
    %
    % Inputs
    % 
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated. The thermal coefficients are within
    %   the field sysData. It is not possible also use a structure in this
    %   case;
    %
    %   maxOrder: integer to specify the maximum order for the models. It
    %   will use the same order for the numerator and denominator of both
    %   system and noise's models.
    %
    %   delayOrders: vector of integer with all the delay values to be
    %   analysed.
    %
    % Outputs
    %
    %   models: struct with the idpolys given as the best result. Each
    %   field has the name of the noise structure.
    %
    % See also arx, oe, armax, bj, iddata, thermalData

    %% Inputs
    
    % Figure options
    figDir = 'outFig';                     % Output figures directory
    colors = ['r','g','b','y'];            % Figure colors
    linSty = ["-"; "--"; "-."; ":"];       % Figure line styles

    % Defaults inputs
    minOrder = 1;
    
    % Optional inputs
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
    
    %% Directories verification and variables config

    analysisName = dataIn.Name;
    if not(isfolder(figDir + "\" + analysisName))
        mkdir(figDir + "\" + analysisName);
    end
    
    % Model parameters
    arxOpt = arxOptions('Focus', 'simulation');
    armaxOpt = armaxOptions('Focus', 'simulation');
    bjOpt = bjOptions('Focus', 'simulation');
    
    % Init variables
    J_oe = zeros(maxOrder-minOrder+1, 3);
    J_arx = zeros(maxOrder-minOrder+1, 3);
    J_armax = zeros(maxOrder-minOrder+1, 3);
    J_bj = zeros(maxOrder-minOrder+1, 3);

    % Transform the data to get a single output system
    dataIn.y = dataIn.y(:,1); % Take one output only
    
    %% Model orders convergence
    
    figLossFunc = figure;
    figFPE = figure;
    figAIC = figure;
    
    for i = 1:length(delayOrders)
        for order = minOrder:maxOrder
    
            % ARX model
            sysARX = arx(dataIn, [order, order+1, delayOrders(i)], arxOpt);
            J_arx(order-minOrder+1, 1) = mag2db(sysARX.report.Fit.LossFcn);
            J_arx(order-minOrder+1, 2) = sysARX.report.Fit.FPE;  
            J_arx(order-minOrder+1, 3) = sysARX.report.Fit.AIC; 
    
            % Init optimization (non linear)
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
    
            % OE model
            sys_init_oe.TimeUnit = 'milliseconds';
            sysOE = oe(dataIn, sys_init_oe);
            J_oe(order-minOrder+1, 1) = 20*log10(sysOE.report.Fit.LossFcn);
            J_oe(order-minOrder+1, 2) = sysOE.report.Fit.FPE;  
            J_oe(order-minOrder+1, 3) = sysOE.report.Fit.AIC; 
    
            % ARMAX model
            sys_init_armax.TimeUnit = 'milliseconds';
            sysARMAX = armax(dataIn, sys_init_armax, armaxOpt);
            J_armax(order-minOrder+1, 1) = ...
                mag2db(sysARMAX.report.Fit.LossFcn);
            J_armax(order-minOrder+1, 2) = sysARMAX.report.Fit.FPE;
            J_armax(order-minOrder+1, 3) = sysARMAX.report.Fit.AIC;
    
            % BJ model
            sys_init_bj.TimeUnit = 'milliseconds';
            sysBJ = bj(dataIn, sys_init_bj, bjOpt);
            J_bj(order-minOrder+1, 1) = mag2db(sysBJ.report.Fit.LossFcn);
            J_bj(order-minOrder+1, 2) = sysBJ.report.Fit.FPE;
            J_bj(order-minOrder+1, 3) = sysBJ.report.Fit.AIC;
        end
    
        % Error criteria
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
    
        % FPE criteria
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
    
        % AIC criteria
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
    
    % Figure for equation error (final configuration)
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
    figLossFunc.Position = [305 52 759 615];
    saveas(figLossFunc, figDir + "\" + analysisName + ...
        "\orderIdent_polyLossFunc.eps");
    sgtitle("Analyse de convergence pour l'erreur d'\'{e}quation", ...
        Interpreter="latex", FontSize=20);
    
    % Figure for FPE error (final configuration)
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
    figFPE.Position = [305 52 759 615];
    saveas(figFPE, figDir+"\"+analysisName+"\orderIdent_polyFPE.eps");
    sgtitle("Analyse de convergence pour l'erreur FPE", ...
        Interpreter="latex", FontSize=20);
    
    % Figure for AIC error (final configuration)
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
    figAIC.Position = [305 52 759 615];
    saveas(figAIC, figDir+"\"+analysisName+"\orderIdent_polyAIC.eps");
    sgtitle("Analyse de convergence pour l'erreur AIC", ...
        Interpreter="latex", FontSize=20);

    %% Outputs
    models.ARX = sysARX;
    models.ARMAX = sysARMAX;
    models.BJ = sysBJ;
    models.OE = sysOE;
end