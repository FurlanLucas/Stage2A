function compare_results(dataIn, varargin)
    %% compare_results
    %
    % Function that compares the theorical results, the numerical ones and
    % also the experimental data measured. The theorical results used are
    % the Pade and Taylor approximations and the numerical method
    % implemented was the finite differences. The compairison are done for
    % 1D and 2D/3D models.
    %
    % Calls
    %
    %   compare_results(dataIn): do the compairison for the data within
    %   dataIn. It has to be a thermal data variable with the system data
    %   within the sysData propertie. It doesnt return any aditional
    %   information;
    %       
    %   compare_results(__, options): take the optional arguments.
    %
    % Inputs
    % 
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated. The thermal coefficients are within
    %   the field sysData. It is not possible also use a structure in this
    %   case.
    %
    % Aditional options
    %
    %   h: heat transfer coefficient for all surfaces with heat loss. If
    %   it is indicated, then hx2 = hy1 = hy2 = hz1 = hz2 = h. If this is
    %   the case, the option to set each heat transfer coefficient is not
    %   available;
    %   
    %   hx2: sets the value for the heat transfer coefficient in the rear
    %   surface (x = ell) in W/(m²K);
    %   
    %   hy1: sets the value for the heat transfer coefficient in the
    %   surface y=0 in W/(m²K). It is used in 3D analysis only. The default
    %   value is 15.
    %   
    %   hy2: sets the value for the heat transfer coefficient in the
    %   surface y=Ly in W/(m²K). It is used in 3D analysis only. The default
    %   value is 15.
    %   
    %   hz1: sets the value for the heat transfer coefficient in the
    %   surface z=0 in W/(m²K). It is used in 3D analysis only. The default
    %   value is 15.
    %   
    %   hz2: sets the value for the heat transfer coefficient in the
    %   surface z=Lz in W/(m²K). It is used in 3D analysis only. The default
    %   value is 15.
    %   
    %   hr2: sets the value for the heat transfer coefficient in the
    %   external surface of the cylinder in W/(m²K). It is used in 2D 
    %   analysis only. The default value is 15.
    %
    % See also model_1d_taylor, model_1d_taylor, finitediff1d, sysDataType,
    % iddata.    

    %% Inputs

    % Fixed inputs
    figDir = 'outFig';

    % Defaults inputs
    hx2 = 15;   % [W/(m²K)] Heat transfer coefficient in x2 surface
    hy1 = 15;   % [W/(m²K)] Heat transfer coefficient in y1 surface   
    hy2 = 15;   % [W/(m²K)] Heat transfer coefficient in y2 surface
    hz1 = 15;   % [W/(m²K)] Heat transfer coefficient in z1 surface
    hz2 = 15;   % [W/(m²K)] Heat transfer coefficient in z2 surface
    hr2 = 15;   % [W/(m²K)] Heat transfer coefficient in r2 surface
    taylorOrder = 10;    % Order for Taylor approximation
    padeOrder = 10;      % Order for Pade approximation
    seriesOrder = 10;    % Order for the series approximation (2D and 3D)
    analysisNumber = 1;  % Number of the dataset to be used.
    
    % Optional inputs
    for i = 1:length(varargin)
        switch varargin{i}
            case 'h' % All heat coefficients
                hx2 = varargin{i+1};
                hy1 = varargin{i+1};
                hy2 = varargin{i+1};
                hz1 = varargin{i+1};
                hz2 = varargin{i+1};
                hr2 = varargin{i+1};
                break;
            case 'hx2'
                hx2 = varargin{i+1};
            case 'hy1'
                hy1 = varargin{i+1};
            case 'hy2'
                hy2 = varargin{i+1};
            case 'hz1'
                hz1 = varargin{i+1};
            case 'hz2'
                hz2 = varargin{i+1};
            case 'hr2'
                hr2 = varargin{i+1};
            case 'taylorOrder'
                taylorOrder = varargin{i+1};
            case 'padeOrder'
                padeOrder = varargin{i+1};
            case 'seriesOrder'
                seriesOrder = varargin{i+1};
            case 'analysisNumber'
                analysisNumber = varargin{i+1};
            
            otherwise % Error
                error("Option << " + varargin{i} + "is not available.");
        end

    end

    %% Other variables for the analysis

    % Take normalization with respect to the area ratio
    phi1D = dataIn.phi{analysisNumber} * dataIn.sysData.takeResArea/...
        dataIn.sysData.takeArea;
    phimultiD = dataIn.phi{analysisNumber};
    t = dataIn.t{analysisNumber}/1e3; % Time vector
    phiV = dataIn.v{analysisNumber}.^2 * ...
        (dataIn.sysData.R/((dataIn.sysData.R_ + dataIn.sysData.R)^2)) ...
        /dataIn.sysData.takeResArea;

    % Take the multidimensional general case
    if strcmp(dataIn.sysData.Geometry, "Cylinder")
        model_multi_pade = @(var1,var2,var3) model_2d_pade(var1, ...
            [hx2, hr2], var2, var3);
        model_multi_taylor= @(var1,var2,var3) model_2d_taylor(var1, ...
            [hx2, hr2], var2, var3);
        type = "2D";
    else
        model_multi_pade = @(var1,var2,var3) model_3d_pade(var1,...
            [h2x, hy1, hy2, hz1, hz2], var2, var3);
        model_multi_taylor= @(var1,var2,var3) model_3d_taylor(var1,...
            [h2x, hy1, hy2, hz1, hz2], var2, var3);
        type = "3D";
    end

    %% Main (simulations)

    % Simulation for Pade in 1D
    fprintf("\tSimulation for Pade model in 1D.\n");
    [~, Fs1d_pade] = model_1d_pade(dataIn, hx2, padeOrder);
    y1d_pade{1} = lsim(Fs1d_pade{1}, phi1D, t); % Rear surface
    y1d_pade{2} = lsim(Fs1d_pade{2}, phi1D, t); % Front surface

    % Simulation for Taylor in 1D
    fprintf("\tSimulation for Taylor model in 1D.\n");
    [~, Fs1d_taylor] = model_1d_taylor(dataIn, hx2, taylorOrder);
    y1d_taylor{1} = lsim(Fs1d_taylor{1}, phi1D, t); % Rear surface
    y1d_taylor{2} = lsim(Fs1d_taylor{2}, phi1D, t); % Front surface

    % Simulation with finite difference in 1D
    fprintf("\tSimulation with finite difference method in 1D.\n");
    [y_findif1d, t_findif1d]  = finitediff1d(dataIn.sysData, t, ...
        phi1D, hx2, 20, 1e6);
    
    % Simulation pour Pade en 3D/2D
    fprintf("\tSimulation for Pade model in " + type + ".\n");
    [~, Fsmulti_pade] = model_multi_pade(dataIn, seriesOrder, ...
        padeOrder);
    ymulti_pade = {zeros(length(y1d_pade{1}), 1), zeros(length(y1d_pade{1}), 1)};
    for i =1:length(Fsmulti_pade)
        ymulti_pade{1} = ymulti_pade{1} + lsim(Fsmulti_pade{i, 1}, ...
            phimultiD, t); % Rear surface
        ymulti_pade{2} = ymulti_pade{2} + lsim(Fsmulti_pade{i, 2}, ...
            phimultiD, t); % Front surface
    end

    % Simulation pour Taylor en 3D/2D
    fprintf("\tSimulation for Taylor model in " + type + ".\n");
    [~,Fsmulti_taylor] = model_multi_taylor(dataIn, seriesOrder, ...
        taylorOrder);
    ymulti_taylor = {zeros(length(y1d_taylor{1}), 1), ...
        zeros(length(y1d_taylor{1}),1)};
    for i =1:length(Fsmulti_taylor)
        ymulti_taylor{1} = ymulti_taylor{1} + lsim(Fsmulti_taylor{i, 1}, ...
            phimultiD, t); % Rear surface
        ymulti_taylor{2} = ymulti_taylor{2} + lsim(Fsmulti_taylor{i, 2}, ...
            phimultiD, t); % Front surface
    end

    % Simulation with finite difference in 2D
    fprintf("\tFinites diffences in 2D.\n");
    [y_findif2d, t_findif2d]  = finitediff2d(dataIn.sysData, t, ...
        phimultiD, [hx2 hr2], 11, 10, 1e5);

    % Simulation with finite difference in 2D v2
    fprintf("\tFinites diffences in 2D (V2).\n");
    [y_findif2d_v2, t_findif2d_v2]  = finitediff2d_v2(dataIn.sysData, t, ...
        phimultiD, [hx2 hr2], 11, 10, 1e5);

    %% Compairison between 1D analysis and experimental results for rear face

    fprintf("\tShowing results.\n");

    fig = figure; hold on;

    % Theorical values
    plot(t/60, dataIn.y_back{analysisNumber}, 'ok', LineWidth=0.1, ...
        MarkerFaceColor='k', MarkerSize=.8);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');

    % Pade 1D
    plot(t/60, y1d_pade{1}, '-.r', LineWidth=2.5);
    h(2) = plot(NaN, NaN, '-.r', DisplayName="Pade 1D", LineWidth=2.5);

    % Taylor 1D
    plot(t/60, y1d_taylor{1}, '--b', LineWidth=2.5);
    h(3) = plot(NaN, NaN, '--b', DisplayName="Taylor 1D", LineWidth=2.5);

    % Finite difference 1D
    plot(t_findif1d/60, y_findif1d{1}, ':g', LineWidth=2.5);
    h(4) = plot(NaN,NaN, ':g', DisplayName="Diff. finite 1D", LineWidth=2.5);

    % Final graph settings
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70]; grid minor;
    saveas(fig, figDir + "\" + dataIn.sysData.Name + ...
        "\compare_theorical_rear_1D", 'epsc');
    
    %% Compairison between 3D analysis and experimental results for rear face

    fig = figure; hold on;

    % Theorical values
    plot(t/60, dataIn.y_back{analysisNumber}, 'ok', LineWidth=0.1, ...
        MarkerFaceColor='k', MarkerSize=.8);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');

    % Pade 3D
    plot(t/60, ymulti_pade{1}, '-.y', LineWidth=2.5);
    h(2) = plot(NaN,NaN, '-.y', DisplayName="Pade "+type,LineWidth=2.5);

    % Taylor 3D
    plot(t/60, ymulti_taylor{1}, '--m', LineWidth=2.5);
    h(3) = plot(NaN, NaN, '--m', DisplayName="Taylor "+type, LineWidth=2.5);

    % Finite difference 3D
    plot(t_findif2d/60, y_findif2d{1}, ':c', LineWidth=2.5);
    h(4) = plot(NaN,NaN, ':c', DisplayName="Diff. finite 2D", LineWidth=2.5);

    % Final graph settings
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70]; grid minor;
    saveas(fig, figDir + "\" + dataIn.sysData.Name + ...
        "\compare_theorical_rear_2D", 'epsc');

    % V2
    fig = figure; hold on; h = [];

    % Theorical values
    plot(t/60, dataIn.y_back{analysisNumber}, 'ok', LineWidth=0.1, ...
        MarkerFaceColor='k', MarkerSize=.8);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');

    % Finite difference 3D
    plot(t_findif2d_v2/60, y_findif2d_v2{1}, ':c', LineWidth=2.5);
    h(2) = plot(NaN,NaN, ':c', DisplayName="Diff. finite", LineWidth=2.5);

    % Final graph settings
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70]; grid minor;
    saveas(fig, figDir + "\" + dataIn.sysData.Name + ...
        "\compare_theorical_rear_2D_v2", 'epsc');


    %% Compairison between 1D analysis and experimental results for front face

    fig = figure; hold on;

    % Theorical values
    plot(t/60, dataIn.y_front{analysisNumber}, 'ok', LineWidth=0.1, ...
        MarkerFaceColor='k', MarkerSize=.8);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');

    % Pade 1D
    plot(t/60, y1d_pade{2}, '-.r', LineWidth=2.5);
    h(2) = plot(NaN, NaN, '-.r', DisplayName="Pade 1D", LineWidth=2.5);

    % Taylor 1D
    plot(t/60, y1d_taylor{2}, '--b', LineWidth=2.5);
    h(3) = plot(NaN, NaN, '--b', DisplayName="Taylor 1D", LineWidth=2.5);

    % Finite difference 1D
    plot(t_findif1d/60, y_findif1d{2}, ':g', LineWidth=2.5);
    h(4) = plot(NaN,NaN, ':g', DisplayName="Diff. finite 1D", LineWidth=2.5);

    % Final graph settings
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70]; grid minor;
    saveas(fig, figDir + "\" + dataIn.sysData.Name + ...
        "\compare_theorical_front_1D", 'epsc');

    %% Compairison between 3D analysis and experimental results for front face

    fig = figure; hold on;

    % Theorical values
    plot(t/60, dataIn.y_front{analysisNumber}, 'ok', LineWidth=0.1, ...
        MarkerFaceColor='k', MarkerSize=.8);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');

    % Pade 3D
    plot(t/60, ymulti_pade{2}, '-.y', LineWidth=2.5);
    h(2) = plot(NaN,NaN, '-.y', DisplayName="Pade "+type,LineWidth=2.5);

    % Taylor 3D
    plot(t/60, ymulti_taylor{2}, '--m', LineWidth=2.5);
    h(3) = plot(NaN, NaN, '--m', DisplayName="Taylor "+type, LineWidth=2.5);

    % Finite difference 3D
    plot(t_findif2d/60, y_findif2d{2}, ':c', LineWidth=2.5);
    h(4) = plot(NaN,NaN, ':c', DisplayName="Diff. finite 2D", LineWidth=2.5);

    % Final graph settings
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70]; grid minor;
    saveas(fig, figDir + "\" + dataIn.sysData.Name + ...
        "\compare_theorical_front_2D", 'epsc');

    % V2
    fig = figure; hold on; h = [];

    % Theorical values
    plot(t/60, dataIn.y_back{analysisNumber}, 'ok', LineWidth=0.1, ...
        MarkerFaceColor='k', MarkerSize=.8);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');

    % Finite difference 3D
    plot(t_findif2d_v2/60, y_findif2d_v2{2}, ':c', LineWidth=2.5);
    h(2) = plot(NaN,NaN, ':c', DisplayName="Diff. finite", LineWidth=2.5);

    % Final graph settings
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70]; grid minor;
    saveas(fig, figDir + "\" + dataIn.sysData.Name + ...
        "\compare_theorical_rear_2D_v2", 'epsc');

    %% Ending and outputs
    fprintf(repmat('\b', 1, 264));

end