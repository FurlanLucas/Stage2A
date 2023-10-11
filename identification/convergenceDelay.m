function all = convergenceDelay(dataIn, analysis, delayOrders, models, varargin)
    %% convergence
    %
    % Function that verifies the model convergence for each noise structure
    % choosen: OE, ARX, ARMAX et BJ. The output is a structure with the
    % idpolys for each model.
    %
    % Calls
    %   
    %   models = convergence(dataIn, delayOrders(2), delayOrders): take the
    %   models with the best convergence in the analysis for a maximum
    %   order of delayOrders(2) and for the delayOrders specified.
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
    %   delayOrders(2): integer to specify the maximum order for the models. It
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
    figDir = analysis.figDir;                     % Output figures directory

    % Defaults inputs
    type = 1;
    
    % Optional inputs
    if ~isempty(varargin)
        for arg = 1:length(varargin)
            switch varargin{arg,1}
                case ("type")
                    type = varargin{arg, 2};
                    break;
            end
        end
    end

    % Model orders
    numOrder = length(models.ARX.B(models.ARX.B~=0)) - 1;
    demOrder = length(models.ARX.A) - 1;
    
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
    J_oe = zeros(delayOrders(2)-delayOrders(1)+1, 3);
    J_arx = zeros(delayOrders(2)-delayOrders(1)+1, 3);
    J_armax = zeros(delayOrders(2)-delayOrders(1)+1, 3);
    J_bj = zeros(delayOrders(2)-delayOrders(1)+1, 3);

    % Transform the data to get a single output system
    dataIn.y = dataIn.y(:,type); % Take one output only
    
    %% Model orders convergence
    
    figLossFunc = figure;

    for orderDelay = delayOrders(1):delayOrders(2)

        % Array position
        pos = orderDelay - delayOrders(1) + 1;
    
        % ARX model
        sysARX = arx(dataIn, [numOrder, demOrder+1, orderDelay], arxOpt);
        J_arx(pos, 1) = mag2db(sysARX.report.Fit.LossFcn);
        J_arx(pos, 2) = sysARX.report.Fit.FPE;  
        J_arx(pos, 3) = sysARX.report.Fit.AIC; 

        % Init optimization (non linear)
        if orderDelay == delayOrders(1)
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
                [sysBJ.D 0], [sysBJ.F 0],sysBJ.NoiseVariance, sysBJ.Ts);
        end

        % OE model
        sys_init_oe.TimeUnit = 'milliseconds';
        sysOE = oe(dataIn, sys_init_oe);
        J_oe(pos, 1) = mag2db(sysOE.report.Fit.LossFcn);
        J_oe(pos, 2) = sysOE.report.Fit.FPE;  
        J_oe(pos, 3) = sysOE.report.Fit.AIC; 

        % ARMAX model
        sys_init_armax.TimeUnit = 'milliseconds';
        sysARMAX = armax(dataIn, sys_init_armax, armaxOpt);
        J_armax(pos, 1) = mag2db(sysARMAX.report.Fit.LossFcn);
        J_armax(pos, 2) = sysARMAX.report.Fit.FPE;
        J_armax(pos, 3) = sysARMAX.report.Fit.AIC;

        % BJ model
        sys_init_bj.TimeUnit = 'milliseconds';
        sysBJ = bj(dataIn, sys_init_bj, bjOpt);
        J_bj(pos, 1) = mag2db(sysBJ.report.Fit.LossFcn);
        J_bj(pos, 2) = sysBJ.report.Fit.FPE;
        J_bj(pos, 3) = sysBJ.report.Fit.AIC;

        all(pos,1).ARX = sysARX;
        all(pos,1).ARMAX = sysARMAX;
        all(pos,1).BJ = sysBJ;
        all(pos,1).OE = sysOE;
    end

    % Error criteria
    figure(figLossFunc);
    subplot(4, 1, 1);  hold on;
    plot(delayOrders(1):delayOrders(2),  J_oe(:, 1), 'r', LineWidth=1.4);
    subplot(4, 1, 2);  hold on;
    plot(delayOrders(1):delayOrders(2), J_arx(:, 1), 'r', LineWidth=1.4);
    subplot(4, 1, 3);  hold on;
    plot(delayOrders(1):delayOrders(2), J_armax(:, 1), 'r', LineWidth=1.4);
    subplot(4, 1, 4);  hold on;
    plot(delayOrders(1):delayOrders(2), J_bj(:, 1), 'r', LineWidth=1.4);

    
    % Figure for equation error (final configuration)
    figure(figLossFunc);
    subplot(4, 1, 1);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "OE"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 2);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "ARX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 3);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "ARMAX"}, Interpreter="latex", FontSize=17);
    subplot(4, 1, 4);  hold off; grid minor;
    ylabel({"Mod\`{e}le", "BJ"}, Interpreter="latex", FontSize=17);
    xlabel("Order $n_k$", Interpreter="latex", FontSize=17);
    figLossFunc.Position = [305 52 759 615];
    saveas(figLossFunc, figDir + "\" + analysisName + "\convergence" + ...
        "\orderIdent_polyLossFunc.eps", 'epsc');
    sgtitle("Analyse de convergence pour l'erreur d'\'{e}quation", ...
        Interpreter="latex", FontSize=20);
    saveas(figLossFunc, figDir + "\" + analysisName + "\convergence" + ...
        "\orderIdent_polyLossFunc.fig");
 

    %% Outputs
    if ~analysis.direct
        msg = 'Press enter to continue...';
        input(msg);
        fprintf(repmat('\b', 1, length(msg)+1));
    end
end