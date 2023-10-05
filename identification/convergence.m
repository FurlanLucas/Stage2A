function models = convergence(dataIn, analysis, maxOrder, delayOrders, varargin)
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
    %   analysis: struct with analysis' name, graph colors and output
    %   directories;
    %
    %   maxOrder: integer to specify the maximum order for the models. It
    %   will use the same order for the numerator and denominator of both
    %   system and noise's models;
    %
    %   delayOrders: vector of integer with all the delay values to be
    %   analysed.
    %
    % Outputs
    %
    %   models: struct with the idpolys given as the best result. Each
    %   field has the name of the noise structure.
    %
    % Aditional options
    %
    %   minOrder: minimal order for the convergence analysis;
    %
    %   type: identifies the outputdata to be considered. By default,
    %   type=1 specifies that will be used the back measured temperature
    %   and type=2 specifies the front temperature.
    %
    % See also arx, oe, armax, bj, iddata, thermalData

    %% Inputs
    
    % Defaults inputs
    minOrder = 2;
    type = 1;
    finalOrder.OE = maxOrder;
    finalOrder.ARX = maxOrder;
    finalOrder.ARMAX = maxOrder;
    finalOrder.BJ = maxOrder;
    
    % Optional inputs
    for i=1:2:length(varargin)        
        switch varargin{i}
            case 'minOrder'
                if minOrder <= maxOrder
                    minOrder = varargin{i+1};
                else
                    error("La valeur de l'ordre minimale doit être"+...
                        "plus petite que celui pour l'ordre" + ...
                        "maximale.");
                end
            case 'type'      
                type = varargin{i+1};
            case 'finalOrder'      
                finalOrder = varargin{i+1};
            otherwise
                error("Option << " + varargin{i} + "is not available.");
        end
    end
    
    %% Directories verification and variables config
    
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
    dataIn.y = dataIn.y(:,type); % Take one output only
    
    %% Model orders convergence
    
    figLossFunc = figure;
    figBIC = figure;
    figAIC = figure;
    
    for i = 1:length(delayOrders)
        for order = minOrder:maxOrder

            % Array position
            pos = order-minOrder+1;
    
            % ARX model
            sysARX = arx(dataIn, [order, order+1, delayOrders(i)], arxOpt);
            J_arx(pos, 1) = mag2db(sysARX.report.Fit.LossFcn);
            J_arx(pos, 2) = sysARX.report.Fit.BIC;  
            J_arx(pos, 3) = sysARX.report.Fit.AIC; 
    
            % Init optimization (non linear)
            if order == minOrder
                sys_init_oe = idpoly(1, sysARX.B, 1, 1, sysARX.A, ...
                    sysARX.NoiseVariance, sysARX.Ts);
                sys_init_armax = idpoly(sysARX.A, sysARX.B, [1 0], 1, 1, ...
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
            J_oe(pos, 1) = mag2db(sysOE.report.Fit.LossFcn);
            J_oe(pos, 2) = sysOE.report.Fit.BIC;  
            J_oe(pos, 3) = sysOE.report.Fit.AIC; 
    
            % ARMAX model
            sys_init_armax.TimeUnit = 'milliseconds';
            sysARMAX = armax(dataIn, sys_init_armax, armaxOpt);
            J_armax(pos, 1) = mag2db(sysARMAX.report.Fit.LossFcn);
            J_armax(pos, 2) = sysARMAX.report.Fit.BIC;
            J_armax(pos, 3) = sysARMAX.report.Fit.AIC;
    
            % BJ model
            sys_init_bj.TimeUnit = 'milliseconds';
            sysBJ = bj(dataIn, sys_init_bj, bjOpt);
            J_bj(pos, 1) = mag2db(sysBJ.report.Fit.LossFcn);
            J_bj(pos, 2) = sysBJ.report.Fit.BIC;
            J_bj(pos, 3) = sysBJ.report.Fit.AIC;

            % Output
            if i == ceil(length(delayOrders)/2)
                if order == finalOrder.OE
                    models.OE = sysOE;
                end
                if order == finalOrder.ARX
                    models.ARX = sysARX;
                end
                if order == finalOrder.ARMAX
                    models.ARMAX = sysARMAX;
                end
                if order == finalOrder.BJ
                    models.BJ = sysBJ;
                end
            end

        end
    
        % Error criteria
        figure(figLossFunc);
        subplot(4, 1, 1);  hold on;
        plot(minOrder:maxOrder,  J_arx(:, 1), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            DisplayName="$n_k = " + num2str(delayOrders(i))+"$", ...
            Marker=analysis.markers(i));
        subplot(4, 1, 2);  hold on;
        plot(minOrder:maxOrder, J_oe(:, 1), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            HandleVisibility='off', Marker=analysis.markers(i));
        subplot(4, 1, 3);  hold on;
        plot(minOrder:maxOrder, J_armax(:, 1), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            HandleVisibility='off', Marker=analysis.markers(i));
        subplot(4, 1, 4);  hold on;
        plot(minOrder:maxOrder, J_bj(:, 1), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            HandleVisibility='off', Marker=analysis.markers(i));
    
        % BIC criteria
        figure(figBIC);
        subplot(4, 1, 1);  hold on;
        plot(minOrder:maxOrder,  J_arx(:, 2), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            DisplayName="$n_k = " + num2str(delayOrders(i))+"$", ...
            Marker=analysis.markers(i));
        subplot(4, 1, 2);  hold on;
        plot(minOrder:maxOrder, J_oe(:, 2), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            HandleVisibility='off', Marker=analysis.markers(i));
        subplot(4, 1, 3);  hold on;
        plot(minOrder:maxOrder, J_armax(:, 2), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            HandleVisibility='off', Marker=analysis.markers(i));
        subplot(4, 1, 4);  hold on;
        plot(minOrder:maxOrder, J_bj(:, 2), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            HandleVisibility='off', Marker=analysis.markers(i));
    
        % AIC criteria
        figure(figAIC);
        subplot(4, 1, 1);  hold on;
        plot(minOrder:maxOrder,  J_arx(:, 3), analysis.colors(i), ...
            LineStyle=analysis.linSty(i),  LineWidth=1.4, ...
            DisplayName="$n_k = " + num2str(delayOrders(i))+"$", ...
            Marker=analysis.markers(i));
        subplot(4, 1, 2);  hold on;
        plot(minOrder:maxOrder, J_oe(:, 3), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            HandleVisibility='off', Marker=analysis.markers(i));
        subplot(4, 1, 3);  hold on;
        plot(minOrder:maxOrder, J_armax(:, 3), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            HandleVisibility='off', Marker=analysis.markers(i));
        subplot(4, 1, 4);  hold on;
        plot(minOrder:maxOrder, J_bj(:, 3), analysis.colors(i), ...
            LineStyle=analysis.linSty(i), LineWidth=1.4, ...
            HandleVisibility='off', Marker=analysis.markers(i));
        
    end
    
    % Figure for equation error (final configuration)
    figure(figLossFunc);
    subplot(4, 1, 1);  hold off; grid minor;
    legend(Interpreter="latex", FontSize=17, Location="northeast", NumColumns=2);
    ylabel("ARX", Interpreter="latex", FontSize=17);
    subplot(4, 1, 2);  hold off; grid minor;
    ylabel("OE", Interpreter="latex", FontSize=17);
    subplot(4, 1, 3);  hold off; grid minor;
    ylabel("ARMAX", Interpreter="latex", FontSize=17);
    subplot(4, 1, 4);  hold off; grid minor;
    ylabel("BJ", Interpreter="latex", FontSize=17);
    xlabel("Ordre $n_a = n_b$", Interpreter="latex", FontSize=17);
    figLossFunc.Position = [305 52 759 615];
    saveas(figLossFunc, analysis.figDir + "\" + analysis.name + ...
        "\orderIdent_polyLossFunc.eps", 'epsc');
    sgtitle("Analyse de convergence pour l'erreur d'\'{e}quation", ...
        Interpreter="latex", FontSize=20);
    
    % Figure for BIC error (final configuration)
    figure(figBIC)
    subplot(4, 1, 1);  hold off; grid minor;
    legend(Interpreter="latex", FontSize=17, Location="northeast");
    ylabel({"Mod\`{e}le", "ARX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 2);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "OE"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 3);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "ARMAX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 4);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "BJ"}, Interpreter="latex", FontSize=17);
    xlabel("Ordre $n_a = n_b$", Interpreter="latex", FontSize=17);
    figBIC.Position = [305 52 759 615];
    saveas(figBIC, analysis.figDir + "\" + analysis.name + ...
        "\orderIdent_polyBIC.eps", 'epsc');
    sgtitle("Analyse de convergence pour l'erreur BIC", ...
        Interpreter="latex", FontSize=20);
    
    % Figure for AIC error (final configuration)
    figure(figAIC);
    subplot(4, 1, 1);  hold off; grid minor;
    legend(Interpreter="latex", FontSize=17, Location="northeast");
    ylabel({"Mod\`{e}le", "ARX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 2);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "OE"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 3);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "ARMAX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 4);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "BJ"}, Interpreter="latex", FontSize=17);
    xlabel("Ordre $n_a = n_b$", Interpreter="latex", FontSize=17);
    figAIC.Position = [305 52 759 615];
    saveas(figAIC, analysis.figDir + "\" + analysis.name + ...
        "\orderIdent_polyAIC.eps", 'epsc');
    sgtitle("Analyse de convergence pour l'erreur AIC", ...
        Interpreter="latex", FontSize=20);

end