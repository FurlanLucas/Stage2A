function compareTaylor_2d(sysData, analysis, h, orders)
    %% compareTaylor_2d
    %
    %

    %% Inputs
    analysisName = sysData.Name;
    figDir = analysis.figDir;
    colors = analysis.colors;

    % Choos the multidimenstional analysis to be used
    if strcmp(sysData.Geometry, "Cylinder") % 2D
        model_multi = @model_2d;
        model_multi_taylor = @model_2d_taylor;
        type = "2D";
    elseif strcmp(sysData.Geometry, "Cube") % 3D
        model_multi = @model_3d;
        model_multi_taylor = @model_3d_taylor;
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
        results_multi_taylor = model_multi_taylor(sysData, h*ones(1, 5), ...
            orders(i), 6);
    
        subplot(2,1,1);
        semilogx(results_multi_taylor.w, ...
            20*log10(results_multi_taylor.mag{1}), ...
            colors(i),LineWidth=1.4, DisplayName="$N="+ ...
            num2str(orders(i))+"$");  
        hold on; subplot(2,1,2); hold on;
        semilogx(results_multi_taylor.w, ...
            results_multi_taylor.phase{1}*180/pi, ...
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
        "\ordersTaylor_2d_rear_en.eps", 'epsc');
    
    % Figure in french
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    subplot(2,1,2);
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    set(thPlot, 'displayName', "Th\'{e}orique");
    saveas(fig, figDir + "\" + analysisName + ...
        "\ordersTaylor_2d_rear_fr.eps", 'epsc');
    sgtitle({"Fonction $G_\varphi(s)$ avec", ...
        "l'approximation de Taylor en " + type}, ...
        Interpreter='latex', FontSize=20);
    
    %% Main code for temperature transfer function 
    
    % Front face model (english)
    fig = figure;
    for i=1:length(orders)
        results_multi_taylor = model_multi_taylor(sysData, h*ones(1, 5), ...
            orders(i), 6);
    
        subplot(2,1,1);
        semilogx(results_multi_taylor.w, ...
            20*log10(results_multi_taylor.mag{2}), ...
            colors(i),LineWidth=1.4, DisplayName="$N="+ ...
            num2str(orders(i))+"$");  
        hold on; subplot(2,1,2); hold on;
        semilogx(results_multi_taylor.w, ...
            results_multi_taylor.phase{2}*180/pi, ...
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
        "\ordersTaylor_2d_front_en.eps", 'epsc');

    % Figure in french
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    subplot(2,1,2);
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    set(thPlot, 'displayName', "Th\'{e}orique");
    saveas(fig, figDir + "\" + analysisName + ...
        "\ordersTaylor_2d_front_fr.eps", 'epsc');
    sgtitle({"Fonction $G_\theta(s)$ avec", ...
        "l'approximation de Taylor en" + type}, ...
        Interpreter='latex', FontSize=20);

end