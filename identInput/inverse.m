function inversed = inverse(models, validData, fs)
    %% inverse
    %
    % Description
    %
    %

    %% Entrées

    figDir = 'outFig';      % [-] Emplacement pour les figures générées ;

    % Prendre
    t = validData.SamplingInstants;

    %% Prendre les données de l'Onera

    disp("Prendre les données d'entrée.");
    [phi, t] = takeExpFlux(fileDataName, fs);

    %% Modèle OE
    N = models.OE.B;
    D = models.OE.F;
    G = tf(N, D, models.OE.Ts);
    G.TimeUnit = models.OE.TimeUnit;

    % Prends les zéros dehors du circle unité
    out_zeros = zpk(G).Z{1}; out_zeros = out_zeros(abs(out_zeros)>=1);

    % Approximation
    gamma = zpk(out_zeros, 1./conj(out_zeros), 1/real(prod(-out_zeros)),...
        models.OE.Ts);
    gamma.TimeUnit = models.OE.TimeUnit;
    Gm = minreal(G/gamma);

    % Pôles et zéros
    figure, pzplot(Gm);

    % Diagramme de bode
    [magG, phaseG, wG] = bode(G); 
    magG = squeeze(magG);
    phaseG = squeeze(phaseG);
    [magGm, phaseGm] = bode(Gm, wG);
    magGm = squeeze(magGm);
    phaseGm = squeeze(phaseGm);
    
    % Figure de bode
    fig = figure; subplot(2, 1, 1); hold on;
    semilogx(wG, mag2db(magG), 'r', LineWidth=1.5, ...
        DisplayName='$G(q^{-1})$');
    semilogx(wG, mag2db(magGm), '--b', LineWidth=1.5, ...
        DisplayName='$G_m(q^{-1})$');
    legend(Location="southwest", Interpreter="latex", FontSize=17);
    ylabel("Module (dB)", Interpreter="latex", FontSize=17);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    subplot(2, 1, 2); hold on;
    semilogx(wG, phaseG, 'r', LineWidth=1.5);
    semilogx(wG, phaseGm, '--b', LineWidth=1.5);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    ylabel("Phase (deg)", Interpreter="latex", FontSize=17);
    xlabel("Fr\'{e}quence (rad/s)", Interpreter="latex", FontSize=17);
    saveas(fig, figDir+"\bode_OE.eps", 'epsc');
    sgtitle({"Approximation pour le", "mod\`{e}le OE"}, ...
        Interpreter="latex", FontSize=23);

    % Simulation temporélle
    u_oe = lsim(1/Gm, validData.y, t);

    % Résultats temporélle
    fig = figure; hold on;
    plot(t/60e3, validData.u/1e3, 'k', LineWidth=1.5, ...
        DisplayName="Donn\'{e}es");
    plot(t/60e3, u_oe/1e3, '--r', LineWidth=1.5, ...
        DisplayName="Estimées");
    grid minor;
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Flux de chaleur (kW/m$^2$)", Interpreter="latex", FontSize=17);
    saveas(fig, figDir+"\temp_OE.eps", 'epsc');
    sgtitle({"Comparaison pour le", "mod\'{e}le OE"}, ...
        Interpreter="latex", FontSize=23);

    % Sortie
    inversed.OE = 1/Gm;

    %% Modèle ARX
    N = models.ARX.B;
    D = models.ARX.A;
    G = tf(N, D, models.ARX.Ts);
    G.TimeUnit = models.ARX.TimeUnit;

    % Prends les zéros dehors du circle unité
    out_zeros = zpk(G).Z{1}; out_zeros = out_zeros(abs(out_zeros)>=1);

    % Approximation
    gamma = zpk(out_zeros, 1./conj(out_zeros), 1/real(prod(-out_zeros)),...
        models.ARX.Ts);
    gamma.TimeUnit = models.ARX.TimeUnit;
    Gm = minreal(G/gamma);

    % Pôles et zéros
    figure, pzplot(Gm);

    % Diagramme de bode
    [magG, phaseG, wG] = bode(G); 
    magG = squeeze(magG);
    phaseG = squeeze(phaseG);
    [magGm, phaseGm] = bode(Gm, wG);
    magGm = squeeze(magGm);
    phaseGm = squeeze(phaseGm);
    
    % Figure
    fig = figure; subplot(2, 1, 1); hold on;
    semilogx(wG, mag2db(magG), 'r', LineWidth=1.5, ...
        DisplayName='$G(q^{-1})$');
    semilogx(wG, mag2db(magGm), '--b', LineWidth=1.5, ...
        DisplayName='$G_m(q^{-1})$');
    legend(Location="southwest", Interpreter="latex", FontSize=17);
    ylabel("Module (dB)", Interpreter="latex", FontSize=17);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    subplot(2, 1, 2); hold on;
    semilogx(wG, phaseG, 'r', LineWidth=1.5);
    semilogx(wG, phaseGm, '--b', LineWidth=1.5);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    ylabel("Phase (deg)", Interpreter="latex", FontSize=17);
    xlabel("Fr\'{e}quence (rad/s)", Interpreter="latex", FontSize=17);
    saveas(fig, figDir+"\bode_OE.eps", 'epsc');
    sgtitle({"Approximation pour le", "mod\`{e}le ARX"}, ...
        Interpreter="latex", FontSize=23);

    % Simulation temporélle
    u_armax = lsim(1/Gm, validData.y, t);

    % Résultats temporélle
    fig = figure; hold on;
    plot(t/60e3, validData.u/1e3, 'k', LineWidth=1.5, ...
        DisplayName="Donn\'{e}es");
    plot(t/60e3, u_armax/1e3, '--r', LineWidth=1.5, ...
        DisplayName="Estimées");
    grid minor;
    xlabel("Temps (min)", Interpreter="latex", FontSize=17);
    ylabel("Flux de chaleur (kW/m$^2$)", Interpreter="latex", FontSize=17);
    saveas(fig, figDir+"\temp_ARX.eps", 'epsc');
    sgtitle({"Comparaison pour le", "mod\'{e}le ARX"}, ...
        Interpreter="latex", FontSize=23);

    % Sortie
    inversed.ARX = 1/Gm;

end