function compare_results(dataIn, varargin)
    %% COMPARE_RESULTS
    %
    % Fonction faite pour comparer le résultat theorique avec celui obtenu
    % en pratique. Les résultats théorique utilisée dans cette fonction 
    % sont :
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
    %   et de Taylor.
    %
    % EXAMPLE D'APPELL:
    %
    %   compare_results(dataIn) : pour analyser les données experimental
    %   dedans dataIn. dataIn doit être une variable du type iddata avec un
    %   champs UserData comme sysDataType.
    %
    %   compare_results(__, options) : pour données des autres options à
    %   l'analyse.
    %
    % OPTIONS
    %   
    %   h : Coefficient de transfert thermique pour les surfaces dans le
    %   modèle théorique. Si il est indiqué, tous les coefficients seront
    %   tels que hx2 = hy1 = hy2 = hz1 = hz2 = h. Si cette option a été
    %   choisit, le choix separé de chaque coefficient ne sera pas
    %   possible.
    %
    %   hx2, hy1, hy2, hz1, hz2 : Coeficientes de transfert thermiques dans
    %   chaque surface.
    %
    %   padeOrder : ordre de l'approximation de Pade dans le modéle
    %   théorique. Cette ordre est utilisée dans le modèle 1d et aussi 3d.
    %
    %   taylorOrder : ordre de l'approximation de Taylor dans le modéle
    %   théorique. Cette ordre est utilisée dans le modèle 1d et aussi 3d.
    %
    %   seriesOrder : ordre de l'approximation en serie pour les deux
    %   modèle 3d. Cette ordre est utilisée dans l'approximation de Pade et
    %   aussi dans l'approximation de Taylor.
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
    
    % Prendre des entrées optionnelles
    if ~isempty(varargin)
        for arg = 1:length(varargin)
            switch varargin{arg}
                case {"h"}
                    hx2 = varargin{arg, 2};
                    hy1 = varargin{arg, 2};
                    hy2 = varargin{arg, 2};
                    hz1 = varargin{arg, 2};
                    hz2 = varargin{arg, 2};
                case {"hx2"}
                    hx2 = varargin{arg, 2};
                case {"hy1"}
                    hy1 = varargin{arg, 2};
                case {"hy2"}
                    hy2 = varargin{arg, 2};
                case {"hz1"}
                    hz1 = varargin{arg, 2};
                case {"hz2"}
                    hz2 = varargin{arg, 2};
                case {"taylorOrder"}
                    taylorOrder = varargin{arg, 2};
                case {"padeOrder"}
                    padeOrder = varargin{arg, 2};
                case {"seriesOrder"}
                    seriesOrder = varargin{arg, 2};
            end
        end
    end

    % Prendre le facteur de trransformation entre les surfaces
    u = dataIn.u * dataIn.UserData.S_res/dataIn.UserData.takeArea;
    t = dataIn.SamplingInstants/1e3; % Vecteur du temps

    %% Main

    % Simulation pour Pade en 1D
    fprintf("\tSimulation pour Pade en 1D.\n");
    [~, Fs1d_pade] = model_1d_pade(dataIn, hx2, padeOrder);
    y1d_pade = lsim(Fs1d_pade, u, t);

    % Simulation pour Taylor en 1D
    fprintf("\tSimulation pour Taylor en 1D.\n");
    [~, Fs1d_taylor] = model_1d_taylor(dataIn, hx2, taylorOrder);
    y1d_taylor = lsim(Fs1d_taylor, u, t);

    % Simulation avec les defferences finites en 1D
    fprintf("\tSimulation pour differences finites en 1D.\n");
    [t_findif1d, y1d_findif1d] = finitediff1d(dataIn, hx2, 20, 1e5);
    
    % Simulation pour Pade en 3D
    fprintf("\tSimulation pour Pade en 3D.\n");
    [~, Fs3d_pade] = model_3d_pade(dataIn, [hx2,hy1,hy2,hz1,hz2], ...
        seriesOrder, padeOrder);
    y3d_pade = 0;
    for i =1:length(Fs3d_pade)
        y3d_pade = y3d_pade + lsim(Fs3d_pade{i}, u, t);
    end

    % Simulation pour Taylor en 3D
    fprintf("\tSimulation pour Taylor en 3D.\n");
    [~,Fs3d_taylor] = model_3d_taylor(dataIn, [hx2,hy1,hy2,hz1,hz2], ...
        seriesOrder, seriesOrder);
    y3d_taylor = 0;
    for i =1:length(Fs3d_pade)
        y3d_taylor = y3d_taylor + lsim(Fs3d_taylor{i}, u, t);
    end

    %% Figure pour la comparaison

    fprintf("\tAffichage des résultats.");

    fig = figure; hold on;
    plot(t/60, dataIn.y, 'ok', LineWidth=0.1, MarkerFaceColor='k', ...
        MarkerSize=0.1);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');
    plot(t/60, y1d_pade, '-.r', LineWidth=2);
    h(2) = plot(NaN, NaN, '-.r', DisplayName="Pade 1D", LineWidth=2);
    plot(t/60, y1d_taylor, '--b',LineWidth=2, DisplayName="Taylor 1D");
    h(3) = plot(NaN, NaN, '--b', DisplayName="Taylor 1D", LineWidth=2);
    plot(t/60, y3d_pade, '-.g', LineWidth=2, DisplayName="Pade 3D");
    h(4) = plot(NaN, NaN, '-.g', DisplayName="Pade 3D", LineWidth=2);
    plot(t/60, y3d_taylor, '--m',LineWidth=2, DisplayName="Taylor 3D");
    h(5) = plot(NaN, NaN, '--m', DisplayName="Taylor 3D", LineWidth=2);
    plot(t_findif1d/60, y1d_findif1d, ':y', LineWidth=2);
    h(6) = plot(NaN, NaN, ':y', DisplayName="Diff. finite", LineWidth=3);
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70]; grid minor;
    saveas(fig, figDir + "\" + dataIn.UserData.name + ...
        "\compare_theorical_", 'epsc');
end