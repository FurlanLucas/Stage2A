function comparePade_2d(sysData, analysis, h, orders)
    %% comparePade_2d
    %
    %

    %% Inputs
    analysisName = sysData.Name;
    figDir = analysis.figDir;
    colors = analysis.colors;

    % Choos the multidimenstional analysis to be used
    if strcmp(sysData.Geometry, "Cylinder") % 2D
        model_multi = @model_2d;
        model_multi_pade = @model_2d_pade;
        type = "2D";
    elseif strcmp(sysData.Geometry, "Cube") % 3D
        model_multi = @model_3d;
        model_multi_pade = @model_3d_pade;
        type = "3D";
    else
        error("Field 'Geometry' is not valid.");
    end

    % Simulation
    results_multi = model_multi(sysData, h*ones(1, 5));

    %% Main code for heat flux transfer function 
    
    % Figure in english
    fig = figure;
    for i=1:length(orders)
        results_multi_pade = model_multi_pade(sysData, h*ones(1, 5), ...
            orders(i), 6);
    
        subplot(2,1,1);
        semilogx(results_multi_pade.w, ...
            20*log10(results_multi_pade.mag{1}), ...
            colors(i),LineWidth=1.4, DisplayName="$N="+ ...
            num2str(orders(i))+"$");  
        hold on; subplot(2,1,2); hold on;
        semilogx(results_multi_pade.w, ...
            results_multi_pade.phase{1}*180/pi, ...
            colors(i), LineWidth=1.4);
    end
    semilogx(results_multi.w, results_multi.phase{1}*180/pi, 'k', ...
        LineWidth=1.4);
    ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); grid minor;
    subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
    thPlot = semilogx(results_multi.w, 20*log10(results_multi.mag{1}), ...
        'k', LineWidth=1.4, DisplayName="Theoretical");  
    leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
        NumColumns=2); 
    leg.ItemTokenSize = [20, 18];
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    saveas(fig, figDir + "\" + analysisName + ...
        "\ordersPade_2d_flux_en.eps", 'epsc');
    
    % Figure in french
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    saveas(fig, figDir + "\" + analysisName + ...
        "\ordersPade_2d_flux_fr.eps", 'epsc');
    set(thPlot, 'displayName', "Th\'{e}orique");
    sgtitle({"Fonction $G_\varphi(s)$ avec", ...
        "l'approximation de Pade en " + type}, ...
        Interpreter='latex', FontSize=20);
    
    %% Main code for temperature transfer function 

    % Figure in english
    fig = figure;
    for i=1:length(orders)
        results_multi_pade = model_multi_pade(sysData, h*ones(1, 5), ...
            orders(i), 6);
    
        subplot(2,1,1);
        semilogx(results_multi_pade.w, ...
            20*log10(results_multi_pade.mag{2}), ...
            colors(i),LineWidth=1.4, DisplayName="$N="+ ...
            num2str(orders(i))+"$");  
        hold on; subplot(2,1,2); hold on;
        semilogx(results_multi_pade.w, ...
            results_multi_pade.phase{2}*180/pi, ...
            colors(i), LineWidth=1.4);
    end
    semilogx(results_multi.w, results_multi.phase{2}*180/pi, 'k', ...
        LineWidth=1.4);
    ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); grid minor;
    subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
    thPlot = semilogx(results_multi.w, 20*log10(results_multi.mag{2}), ...
        'k', LineWidth=1.4, DisplayName="Theoretical");  
    leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
        NumColumns=2); 
    leg.ItemTokenSize = [20, 18];
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    saveas(fig, figDir + "\" + analysisName + ...
        "\ordersPade_2d_temp_en.eps", 'epsc');
    
    % Figure in french
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    subplot(2,1,2);
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    set(thPlot, 'displayName', "Th\'{e}orique");
    saveas(fig, figDir + "\" + analysisName + ...
        "\ordersPade_2d_temp_fr.eps", 'epsc');
    sgtitle({"Fonction $G_\theta(s)$ avec","l'approximation de Pade en "...
        + type}, Interpreter='latex', FontSize=20);

end