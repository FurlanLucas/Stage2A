function compare_results(dataIn, varargin)
    %% compare_results
    %
    %   Fonction faite pour comparer le résultat theorique avec celui obtenu
    %   en pratique. Les résultats théorique utilisée dans cette fonction 
    %   sont :
    %
    %   -> Differences finites en 1D. La fonction finitediff1d est la
    %   responsable pour faire le calcule, sachant qu'elle utilise une
    %   approche implicite.
    %
    %   -> Approximation théorique en 1D. Ils sont utilisés deux
    %   approximation, l'approximation de Pade et de Taylor de la fonction
    %   transfer F(s). 
    % 
    %   -> Approximation théorique en 3D. Ils sont utilisés deux
    %   approximations differentes comme en 1D : l'approximation de Pade
    %   et de Taylor. S'il y a de axisimetrie, il est utilisée une analyse
    %   2D.
    %
    %   Appels:
    %
    %       compare_results(dataIn) : pour analyser les données experimental
    %       dedans dataIn. dataIn doit être une variable du type iddata avec 
    %       un champs UserData comme sysDataType.
    %       
    %       compare_results(__, options) : pour données des autres options à
    %       l'analyse.
    %
    %   Entrées :
    % 
    %   - dataIn : variable iddata avec l'entrée qui va être simulée. Les
    %   information des coefficients thermiques du material et les autres
    %   carachteristiques comme la masse volumique sont estoquées dans le
    %   champs UserData dedans dataIn. Il sera estoqué comme sysDataType.
    %
    %   Sorties :
    %   
    %   - bodeOut : structure avec le résultat de l'analyse qui contien les
    %   champs bodeOut.w avec les fréquences choisit, bodeOut.mag avec la
    %   magnitude et bodeOut.phase avec les données de phase. Les variables
    %   bodeOut.mag et bodeOut.phase sont des celulles 1x2 avec des valeurs
    %   pour la face arrière {1} et avant {2}.
    %   - Fs_pade : function de transfert (variable tf) avec
    %   l'approximation de Pade. Il est une celulle 1x2 avec des résultats
    %   pour la face arrière {1} et avant {2}.
    %
    %   Entrées optionnelles :
    %   
    %   - h : Coefficient de transfert thermique pour les surfaces dans le
    %   modèle théorique. Si il est indiqué, tous les coefficients seront
    %   tels que hx2 = hy1 = hy2 = hz1 = hz2 = h. Si cette option a été
    %   choisit, le choix separé de chaque coefficient ne sera pas
    %   possible.
    %
    % See also model_1d_taylor, model_1d_taylor, finitediff1d, sysDataType,
    % iddata.
    
    %% Entrées

    % Entrées immuables
    figDir = 'outFig';

    % Entrées defaults
    hx2 = 15;   % [W/m^2]   Coefficient de transfert thermique pour x2 ;
    hy1 = 15;   % [W/m^2]   Coefficient de transfert thermique pour y1 ;   
    hy2 = 15;   % [W/m^2]   Coefficient de transfert thermique pour y2 ;
    hz1 = 15;   % [W/m^2]   Coefficient de transfert thermique pour z1 ;
    hz2 = 15;   % [W/m^2]   Coefficient de transfert thermique pour z2 ;
    taylorOrder = 10;   % [-] Ordre de l'approximation de Taylor ;
    padeOrder = 10;     % [-] Ordre de l'approximation de Pade ;
    seriesOrder = 10;   % [-] Ordre de la serie (nombre des elements) ;
    analyseNumber = 1;
    
    % Prendre les entrées optionnelles
    for i = 1:length(varargin)
        switch varargin{i}
            case 'h'
                hx2 = varargin{i+1};
                hy1 = varargin{i+1};
                hy2 = varargin{i+1};
                hz1 = varargin{i+1};
                hz2 = varargin{i+1};
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
            case 'taylorOrder'
                taylorOrder = varargin{i+1};
            case 'padeOrder'
                padeOrder = varargin{i+1};
            case 'seriesOrder'
                seriesOrder = varargin{i+1};
        end

    end

    %% Autres variables et configurations

    % Prendre le facteur de transformation entre les surfaces (1D)
    u = dataIn.phi{analyseNumber} * dataIn.sysData.takeResArea/...
        dataIn.sysData.takeArea;

    t = dataIn.t{analyseNumber}/1e3; % Vecteur du temps

    % Prendre le type d'analyse multidimensional
    if strcmp(dataIn.sysData.Geometry, "Cylinder")
        model_multi_pade = @(var1, var2, var3, var4) model_2d_pade(var1,...
            var2, var3, var4);
        model_multi_taylor= @(var1,var2,var3,var4) model_2d_taylor(var1,...
            var2,var3, var4);
        type = "2D";
    else
        model_multi_pade = @(var1, var2, var3, var4) model_3d_pade(var1,...
            var2, var3, var4);
        model_multi_taylor= @(var1,var2,var3,var4) model_3d_taylor(var1,...
            var2, var3, var4);
        type = "3D";
    end

    %% Main

    % Simulation pour Pade en 1D
    fprintf("\tSimulation pour Pade en 1D.\n");
    [~, Fs1d_pade] = model_1d_pade(dataIn, hx2, padeOrder);
    y1d_pade{1} = lsim(Fs1d_pade{1}, u, t);
    y1d_pade{2} = lsim(Fs1d_pade{2}, u, t);

    % Simulation pour Taylor en 1D
    fprintf("\tSimulation pour Taylor en 1D.\n");
    [~, Fs1d_taylor] = model_1d_taylor(dataIn, hx2, taylorOrder);
    y1d_taylor{1} = lsim(Fs1d_taylor{1}, u, t);
    y1d_taylor{2} = lsim(Fs1d_taylor{2}, u, t);

    % Simulation avec les defferences finites en 1D
    fprintf("\tSimulation pour differences finites en 1D.\n");
    [y_findif1d, t_findif1d]  = finitediff1d(dataIn.sysData, t, ...
        u, hx2, 20, 1e6);
    
    % Simulation pour Pade en 3D/2D
    fprintf("\tSimulation pour Pade en " + type + ".\n");
    [~, Fsmulti_pade] = model_multi_pade(dataIn, [hx2,hy1,hy2,hz1,hz2], ...
        seriesOrder, padeOrder);
    ymulti_pade = {zeros(length(y1d_pade{1}), 1), zeros(length(y1d_pade{1}), 1)};
    for i =1:length(Fsmulti_pade)
        ymulti_pade{1} = ymulti_pade{1} + lsim(Fsmulti_pade{i, 1}, ...
            dataIn.phi{analyseNumber}, t);
        ymulti_pade{2} = ymulti_pade{2} + lsim(Fsmulti_pade{i, 2}, ...
            dataIn.phi{analyseNumber}, t);
    end

    % Simulation pour Taylor en 3D/2D
    fprintf("\tSimulation pour Taylor en " + type + ".\n");
    [~,Fsmulti_taylor] = model_multi_taylor(dataIn, [hx2,hy1,hy2,hz1,...
        hz2], seriesOrder, taylorOrder);
    ymulti_taylor = {zeros(length(y1d_taylor{1}), 1), ...
        zeros(length(y1d_taylor{1}),1)};
    for i =1:length(Fsmulti_taylor)
        ymulti_taylor{1} = ymulti_taylor{1} + ...
            lsim(Fsmulti_taylor{i, 1}, dataIn.phi{analyseNumber}, t);
        ymulti_taylor{2} = ymulti_taylor{2} + ...
            lsim(Fsmulti_taylor{i, 2}, dataIn.phi{analyseNumber}, t);
    end

    % Simulation avec les defferences finites en 2D
    fprintf("\tSimulation pour differences finites en 2D.\n");
    [y_findif2d, t_findif2d]  = finitediff2d_v2(dataIn.sysData, t, ...
        dataIn.phi{analyseNumber}, hx2, 10, 20, 1e5);

    %% Figure pour la comparaison des résultats dasn la face arrière 1D

    fprintf("\tAffichage des résultats.\n\n");

    fig = figure; hold on;

    % Valeurs théoriques
    plot(t/60, dataIn.y_back{analyseNumber}, 'ok', LineWidth=0.1, ...
        MarkerFaceColor='k', MarkerSize=.8);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');

    % Pade 1D
    plot(t/60, y1d_pade{1}, '-.r', LineWidth=2.5);
    h(2) = plot(NaN, NaN, '-.r', DisplayName="Pade 1D", LineWidth=2.5);

    % Taylor 1D
    plot(t/60, y1d_taylor{1}, '--b', LineWidth=2.5);
    h(3) = plot(NaN, NaN, '--b', DisplayName="Taylor 1D", LineWidth=2.5);

    % Différences finies 1D
    plot(t_findif1d/60, y_findif1d{1}, ':c', LineWidth=2.5);
    h(4) = plot(NaN,NaN, ':c', DisplayName="Diff. finite 2D", LineWidth=2.5);

    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70]; grid minor;
    saveas(fig, figDir + "\" + dataIn.sysData.Name + ...
        "\compare_theorical_1D", 'epsc');


    %% Figure pour la comparaison des résultats dasn la face arrière 3D

    fprintf("\tAffichage des résultats.\n\n");

    fig = figure; hold on;

    % Valeurs théoriques
    plot(t/60, dataIn.y_back{analyseNumber}, 'ok', LineWidth=0.1, ...
        MarkerFaceColor='k', MarkerSize=.8);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');

    % Pade 3D
    plot(t/60, ymulti_pade{1}, '-.g', LineWidth=2.5);
    h(2) = plot(NaN,NaN, '-.g', DisplayName="Pade "+type,LineWidth=2.5);

    % Taylor 3D
    plot(t/60, ymulti_taylor{1}, '--m', LineWidth=2.5);
    h(3) = plot(NaN, NaN, '--m', DisplayName="Taylor "+type, LineWidth=2.5);

    % Différences finies 3D
    plot(t_findif2d/60, y_findif2d{1}, ':c', LineWidth=2.5);
    h(4) = plot(NaN,NaN, ':c', DisplayName="Diff. finite 2D", LineWidth=2.5);

    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70]; grid minor;
    saveas(fig, figDir + "\" + dataIn.sysData.Name + ...
        "\compare_theorical_3D", 'epsc');

    %% Figure pour la comparaison des résultats dasn la face avant

    fprintf("\tAffichage des résultats.\n\n");

    fig = figure; hold on;

    % Valeurs théoriques
    plot(t/60, dataIn.y_front{analyseNumber}, 'ok', LineWidth=0.1, ...
        MarkerFaceColor='k', MarkerSize=.8);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');

    % Pade 1D
    plot(t/60, y1d_pade{2}, '-.r', LineWidth=2.5);
    h(2) = plot(NaN, NaN, '-.r', DisplayName="Pade 1D", LineWidth=2.5);

    % Taylor 1D
    plot(t/60, y1d_taylor{2}, '--b', LineWidth=2.5);
    h(3) = plot(NaN, NaN, '--b', DisplayName="Taylor 1D", LineWidth=2.5);

    % Différences finies 1D
    plot(t_findif1d/60, y_findif1d{2}, ':y', LineWidth=2.5);
    h(4) = plot(NaN,NaN, ':y', DisplayName="Diff. finite 1D", LineWidth=2.5);

    % Pade 3D
    plot(t/60, ymulti_pade{2}, '-.g', LineWidth=2.5);
    h(5) = plot(NaN,NaN, '-.g', DisplayName="Pade "+type,LineWidth=2.5);

    % Taylor 3D
    plot(t/60, ymulti_taylor{2}, '--m', LineWidth=2.5);
    h(6) = plot(NaN, NaN, '--m', DisplayName="Taylor "+type, LineWidth=2.5);

    % Différences finies 3D
    plot(t_findif2d/60, y_findif2d{2}, ':c', LineWidth=2.5);
    h(7) = plot(NaN,NaN, ':c', DisplayName="Diff. finite 2D", LineWidth=2.5);

    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70]; grid minor;
    saveas(fig, figDir + "\" + dataIn.sysData.Name + ...
        "\compare_theorical_", 'epsc');
end