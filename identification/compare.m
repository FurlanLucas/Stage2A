function compaire(dataIn)
    %% COMPAIRE
    %
    % Fonction faite pour comparer le résultat theorique avec celui obtenu
    % en pratique
    
    %% Entrées
    h = 15;
    factor = dataIn.UserData.S_res/dataIn.UserData.takeArea;
    factor = 0.7;
    t = dataIn.SamplingInstants/1e3;

    %% Main

    % Simulation pour Pade en 1D
    [~, Fs1d_pade] = model_1d_pade(dataIn, h, 8);
    y1d_pade = lsim(Fs1d_pade, dataIn.u*factor, t);

    % Simulation pour Taylor en 1D
    [~, Fs1d_taylor] = model_1d_taylor(dataIn, h, 8);
    y1d_taylor = lsim(Fs1d_taylor, dataIn.u*factor, t);

    % Simulation avec les defferences finites en 1D
    [t_findif1d, y1d_findif1d] = finitediff1d(dataIn, h, 20, 1e5);
    
    % Simulation pour Pade en 3D
    [~, Fs3d_pade] = model_3d_pade(dataIn, h*ones(1,5), 6, 10);
    y3d_pade = 0;
    for i =1:length(Fs3d_pade)
        y3d_pade = y3d_pade + lsim(Fs3d_pade{i}, dataIn.u*factor, t);
    end

    % Simulation pour Taylor en 3D
    [~, Fs3d_taylor] = model_3d_taylor(dataIn, h*ones(1,5), 6, 10);
    y3d_taylor = 0;
    for i =1:length(Fs3d_pade)
        y3d_taylor = y3d_taylor + lsim(Fs3d_taylor{i}, dataIn.u*factor, t);
    end

    fig = figure; hold on;
    plot(t/60, dataIn.y, 'ok', LineWidth=0.1, MarkerFaceColor='k', ...
        MarkerSize=0.1);
    h(1) = plot(NaN, NaN, 'ok', DisplayName="Donn\'{e}es", ...
        MarkerSize=7, MarkerFaceColor='k');
    plot(t/60, y1d_pade, '-.r', LineWidth=2);
    h(2) = plot(NaN, NaN, '-.r', DisplayName="Pade 1D");
    plot(t/60, y1d_taylor, '--b',LineWidth=2, DisplayName="Taylor 1D");
    h(3) = plot(NaN, NaN, '--b', DisplayName="Taylor 1D");
    plot(t/60, y3d_pade, '-.g', LineWidth=2, DisplayName="Pade 3D");
    h(4) = plot(NaN, NaN, '-.g', DisplayName="Pade 3D");
    plot(t/60, y3d_taylor, '--m',LineWidth=2, DisplayName="Taylor 3D");
    h(5) = plot(NaN, NaN, '--m', DisplayName="Taylor 3D");
    plot(t_findif1d/60, y1d_findif1d, ':y', LineWidth=2);
    h(6) = plot(NaN, NaN, ':y', DisplayName="Diff. finite");
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", FontSize=17);
    leg = legend(h,Location="southeast", Interpreter="latex", FontSize=17);
    leg.ItemTokenSize = [30, 70];
    grid minor; 
end