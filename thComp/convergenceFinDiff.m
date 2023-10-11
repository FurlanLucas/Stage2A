function convergenceFinDiff(sysData, varargin)
    %% convergenceFinDiff
    %
    %

    %% Inputs
    figDir = 'figOut';
    h = 10;
    Tmax = 40; % [s] Maximum time of simulation
    dt = 1e-3;    % [s] Simulation time step
    colors = ['b', 'r', 'g', 'm'];
    markers = ["square"; "o"; "^"; "x"];

    %% Convergence in 1D
    [diff1d, ~, Mx1d] = comp1D(sysData, h, dt, Tmax);

    % Figure for convergence - english
    fig = figure; hold on;
    plot(Mx1d, diff1d{1}, '-r', LineWidth=1.7, Marker='o', ...
        DisplayName="Pad\'{e}");
    plot(Mx1d, diff1d{2}, '-b', LineWidth=1.7, Marker='square', ...
        DisplayName='Taylor');
    grid minor;
    legend(Location='northeast', Interpreter='latex', FontSize=17);
    ylabel('Mean error', Interpreter='latex', FontSize=17);
    xlabel('Order $M_x$', Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\convergence_findiff1D_en.eps", 'epsc');   

    % Figure for convergence - french   
    ylabel("Crit\`{e}re d'erreur", Interpreter='latex', FontSize=17);
    xlabel('Ordre $M_x$', Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\convergence_findiff1D_fr.eps", 'epsc');  

    %% Time response

    t = 0:1:8*60*60;
    u = ones(size(t));

    % Pade
    [~, Fs_pade] = model_1d_taylor(sysData, h, 6);
    y_pade = lsim(Fs_pade{1}, u, t);

    % Taylor
    [~, Fs_taylor] = model_1d_taylor(sysData, h, 6);
    y_taylor = lsim(Fs_taylor{1}, u, t);

    % Fin diff
    y_finDiff  = finitediff1d(sysData, t, u, h, 10, length(t));

    % Figure for time response - french
    fig = figure; hold on;
    plot(t/3600, y_pade, '-r', LineWidth=1.7, ...
        DisplayName="Pad\'{e}");
    plot(t/3600, y_taylor, '-b', LineWidth=1.7, ...
        DisplayName='Taylor');
    plot(t/3660, y_finDiff{1}, '-.g', LineWidth=1.7, ...
        DisplayName='Diff. finies');
    grid minor;
    legend(Location='northeast', Interpreter='latex', FontSize=17);
    ylabel("Temp\'{e}rature ($^\circ$)", Interpreter='latex', FontSize=17);
    xlabel('Temps (h)', Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\timeResponse_1D_fr.eps", 'epsc'); 

    %% Convergence in 2D/3D
    [diff2d, Mx2d, Mr2d] = comp2D(sysData, h, dt, Tmax);

    % Figure for convergence - english
    fig = figure; hold on;
    for j = 1:length(Mr2d)
        plot(Mx2d, diff2d{1}(:,j), '-', Color=colors(j), ...
            LineWidth=1.7, Marker=markers(j), DisplayName="$M_r$="+...
            Mr2d(j));
    end
    grid minor;
    legend(Location='northeast', Interpreter='latex', FontSize=17);
    ylabel('Mean error', Interpreter='latex', FontSize=17);
    xlabel('Order $M_x$', Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\convergence_findiff2D_en.eps", 'epsc');   

    % Figure for convergence - french   
    ylabel('Erreur moyenne', Interpreter='latex', FontSize=17);
    xlabel('Ordre $M_x$', Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\convergence_findiff2D_fr.eps", 'epsc');  

end