function compare_1d2d(sysData, analysis, h)
    %% compare_1d2h()
    %
    %

    %% Inputs
    analysisName = sysData.Name;
    figDir = analysis.figDir;
    seriesOrder = 6;

    % Choos the multidimenstional analysis to be used
    if strcmp(sysData.Geometry, "Cylinder") % 2D
        model_multi = @model_2d;
        type = "2D";
    elseif strcmp(sysData.Geometry, "Cube") % 3D
        model_multi = @model_3d;
        type = "3D";
    else
        error("Field 'Geometry' is not valid.");
    end
    
    % Simulation
    results_1d = model_1d(sysData, h, wmin=1e-5, wmax=1e-1);
    results_multi = model_multi(sysData, h*ones(1, 5), seriesOrder, ...
        wmin=1e-5, wmax=1e-1);

    %% Main code for heat flux transfer function

    % Figure in english
    fig = figure; subplot(2,1,1); hold on;
    th1Plot = plot(results_1d.w, 20*log10(results_1d.mag{1}), 'b', ...
        LineWidth=1.4, DisplayName="Model 1D"); 
    th2Plot = plot(results_multi.w, 20*log10(results_multi.mag{1}), '--r', ...
        LineWidth=1.4, DisplayName="Model " + type);
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    legend(Location='southwest', Interpreter='latex', FontSize=15); 
    grid minor; hold off; set(gca, 'XScale', 'log'); subplot(2,1,2); hold on;
    plot(results_1d.w, results_1d.phase{1}*180/pi, 'b', LineWidth=1.4); 
    plot(results_multi.w, results_multi.phase{1}*180/pi, '--r', LineWidth=1.4); 
    ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequency (rad/s)",Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    saveas(fig, figDir + "\" + analysisName + ...
        "\compaire_1d2d_flux_en.eps", 'epsc');
    
    % Figure in french
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    subplot(2,1,2);
    set(th1Plot, 'displayName', "Mod\'{e}le 1D");
    set(th2Plot, 'displayName', "Mod\'{e}le " + type);
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    saveas(fig, figDir + "\" + analysisName + ...
        "\compaire_1d2d_flux_fr.eps", 'epsc');
    sgtitle("Fonction $G_\varphi(s)$ en 1D et 2D", ...
        Interpreter='latex', FontSize=20);

    %% Main code for temperature function

    % Figure in english
    fig = figure; subplot(2,1,1); hold on;
    th1Plot = plot(results_1d.w, 20*log10(results_1d.mag{2}), 'b', ...
        LineWidth=1.4, DisplayName="Model 1D"); 
    th2Plot = plot(results_multi.w, 20*log10(results_multi.mag{2}), '--r', ...
        LineWidth=1.4, DisplayName="Model " + type);
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    legend(Location='southwest', Interpreter='latex', FontSize=15); 
    grid minor; hold off; set(gca, 'XScale', 'log'); subplot(2,1,2); hold on;
    plot(results_1d.w, results_1d.phase{2}*180/pi, 'b', LineWidth=1.4); 
    plot(results_multi.w, results_multi.phase{2}*180/pi, '--r', LineWidth=1.4); 
    ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequency (rad/s)",Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    saveas(fig, figDir + "\" + analysisName + ...
        "\compaire_1d2d_temp_en.eps", 'epsc');
    
    % Figure in french
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    subplot(2,1,2);
    set(th1Plot, 'displayName', "Mod\'{e}le 1D");
    set(th2Plot, 'displayName', "Mod\'{e}le " + type);
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    saveas(fig, figDir + "\" + analysisName + ...
        "\compaire_1d2d_temp_fr.eps", 'epsc');
    sgtitle("Fonction $G_\theta(s)$ en 1D et 2D", ...
        Interpreter='latex', FontSize=20);

end