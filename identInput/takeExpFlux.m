function [phi, t] = takeExpFlux(fileDataName)
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
    

end