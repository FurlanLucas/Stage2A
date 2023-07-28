function [new_phi, new_t] = takeExpFlux(fileDataName, fs)
    %% takeExpFlux
    %
    % Description
    %

    %% Entrées
    figDir = 'outFig';     % [-] Emplacement pour les figures générées ;

    % Données
    reentryData = unique(readtable(fileDataName));
    t = reentryData.x - reentryData.x(1);
    phi = reentryData.y;
    dt = t(2:end) - t(1:end-1);
    t = t(dt~=0); phi = phi(dt~=0);
    
    %% Figure des données (brut)
    fig = figure;
    plot(t/60, phi, 'r', LineWidth=1.5);
    grid minor;
    ylabel("Flux de chaleur (kW/m$^2$)", Interpreter="latex", FontSize=17);
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    saveas(fig, figDir + "\donnéesDeentree.eps", 'epsc');
    title("Donn\'{e}es d'entr\'{e}e", Interpreter="latex", FontSize=23);
    
    new_t = 0:1/fs:t(end);
    new_phi = interp1(t, phi, new_t);
    
    %% Figure des données (interpolées)
    fig = figure;
    plot(new_t/60, new_phi, 'r', LineWidth=1.5);
    grid minor;
    ylabel("Flux de chaleur (kW/m$^2$)", Interpreter="latex", FontSize=17);
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    saveas(fig, figDir + "\donnéesDeentree.eps", 'epsc');
    title("Donn\'{e}es interpol\'{e}es", Interpreter="latex", FontSize=23);

    %% Sortie
    new_t = new_t*1e3;

end