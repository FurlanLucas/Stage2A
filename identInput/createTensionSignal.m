function signal = createTensionSignal(models, phi, t, fs)
    %% createTesionSignal
    %
    %
    %

    %% Entrées
    figDir = 'outFig';
    outFileName = 'outFile.csv'; % [-] Nom du fichier de sortie ;
    medianOrder = 20;            % [-] Ordre du filtre medien ;
    maxPhi = 10e3;               % [W/m²] Flux de chaleur maximale ;
    model2File = 'OE';           % [-] Model to be saved ;

    % Données de sortie
    t_out = 0:1/fs:t(end);

    %% Modele OE
    models.OE = chgTimeUnit(models.OE,'seconds');
    
    % Données 
    new_t = 0:models.OE.Ts:t(end);
    phi = medfilt1(phi*1e3);
    new_phi = interp1(t, phi, new_t);
    new_phi = new_phi/max(new_phi);

    % Figure nouvelles données normalisée
    fig = figure;
    plot(new_t/60, new_phi, 'r', Linewidth=1.5);
    grid minor;
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Flux de chaleur (-)", Interpreter="latex", FontSize=17);
    saveas(fig, figDir + "DataInterpolated_OE.eps", 'epsc');
    title({"Flux de chaleur normalis\'{e}e ONERA", "mod\'{e}le OE"}, ...
        Interpreter="latex", FontSize=23);

    % Simulation inverse
    signal.OE = lsim(models.OE, new_phi*maxPhi, new_t);

    % Figure de la simulation inverse (tension au carré)
    fig = figure;
    plot(new_t/60, signal.OE, 'r', Linewidth=1.5);
    grid minor;
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Tension au carr\'{e} (V$^2$)",Interpreter="latex",FontSize=17);
    saveas(fig, figDir + "DataInterpolated_OE.eps", 'epsc');
    title({"Tension en entr\'{e}e au carr\'{e}", "mod\'{e}le OE"}, ...
        Interpreter="latex", FontSize=23);

    signal.OE = medfilt1(sqrt(signal.OE), medianOrder);
    signal.OE = interp1(new_t, signal.OE, t_out);

    % Figure de la simulation inverse (en tension, filtré et échantilloné)
    fig = figure;
    plot(t_out/60, signal.OE, 'r', Linewidth=1.5);
    grid minor;
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Tension (V)",Interpreter="latex",FontSize=17);
    saveas(fig, figDir + "DataInterpolated_OE.eps", 'epsc');
    title({"Tension en entr\'{e}e", "mod\'{e}le OE"}, ...
        Interpreter="latex", FontSize=23);

    %% Modele ARX
    models.ARX = chgTimeUnit(models.OE,'seconds');
    
    % Données 
    new_t = 0:models.ARX.Ts:t(end);
    phi = medfilt1(phi*1e3);
    new_phi = interp1(t, phi, new_t);
    new_phi = new_phi/max(new_phi);

    % Figure nouvelles données normalisée
    fig = figure;
    plot(new_t/60, new_phi, 'r', Linewidth=1.5);
    grid minor;
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Flux de chaleur (-)", Interpreter="latex", FontSize=17);
    saveas(fig, figDir + "DataInterpolated_OE.eps", 'epsc');
    title({"Flux de chaleur normalis\'{e}e ONERA", "mod\'{e}le ARX"}, ...
        Interpreter="latex", FontSize=23);

    % Simulation inverse
    signal.ARX = lsim(models.ARX, new_phi*maxPhi, new_t);

    % Figure de la simulation inverse (tension au carré)
    fig = figure;
    plot(new_t/60, signal.ARX, 'r', Linewidth=1.5);
    grid minor;
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Tension au carr\'{e} (V$^2$)",Interpreter="latex",FontSize=17);
    saveas(fig, figDir + "DataInterpolated_OE.eps", 'epsc');
    title({"Tension en entr\'{e}e au carr\'{e}", "mod\'{e}le ARX"}, ...
        Interpreter="latex", FontSize=23);

    signal.ARX = medfilt1(sqrt(signal.ARX), medianOrder);
    signal.ARX = interp1(new_t, signal.ARX, t_out);

    % Figure de la simulation inverse (en tension, filtré et échantilloné)
    fig = figure;
    plot(t_out/60, signal.ARX, 'r', Linewidth=1.5);
    grid minor;
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Tension (V)",Interpreter="latex",FontSize=17);
    saveas(fig, figDir + "DataInterpolated_OE.eps", 'epsc');
    title({"Tension en entr\'{e}e", "mod\'{e}le ARX"}, ...
        Interpreter="latex", FontSize=23);

    %% Sortie

    if strcmp(model2File, 'OE')
        writematrix(signal.OE, outFileName);
    elseif strcmp(model2File, 'ARX')
        writematrix(signal.ARX, outFileName);
    end


end