function comparePade_1d(sysData, analysis, h, orders)
    %% compairePade_1d
    %
    % Simulate a comparison

    %% Inputs
    analysisName = sysData.Name;
    figDir = analysis.figDir;
    colors = analysis.colors;

    % Simulation
    results_1d_th = model_1d(sysData, h); % Theoretical result

    %% Main code for heat flux transfer function    
    
    % Figure in english
    fig = figure;
    for i=1:length(orders)
        results_1d = model_1d_pade(sysData, h, orders(i));
        subplot(2,1,1);
        semilogx(results_1d.w, 20*log10(results_1d.mag{1}), colors(i), ...
            LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
        hold on; subplot(2,1,2); hold on;
        semilogx(results_1d.w, results_1d.phase{1}*180/pi, colors(i), ...
            LineWidth=1.4);
    end
    semilogx(results_1d_th.w, results_1d_th.phase{1}*180/pi, 'k', ...
        LineWidth=1.4);
    ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); grid minor;
    subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
    thPlot = semilogx(results_1d_th.w, 20*log10(results_1d_th.mag{1}), ...
        'k', LineWidth=1.4, DisplayName="Theoretical");  
    leg = legend(Location='southwest', Interpreter='latex', FontSize=15,...
        NumColumns=2); 
    leg.ItemTokenSize = [20, 18];
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    saveas(fig, figDir + "\" + analysisName + ...
        "\ordersPade_1d_flux_en.eps", 'epsc');
    
    % Figure in french
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    subplot(2,1,2);
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    set(thPlot, 'displayName', "Th\'{e}orique");
    saveas(fig, figDir + "\" + analysisName + ...
        "\ordersPade_1d_flux_fr.eps", 'epsc');
    sgtitle({"Fonction $G_\varphi(s)$ avec", ...
        "l'approximation de Pade en 1D"}, ...
        Interpreter='latex', FontSize=20);
    
    %% Main code for temperature transfer function   

    % Figure in english
    fig = figure;
    for i=1:length(orders)
        results_1d = model_1d_pade(sysData, h, orders(i));
        subplot(2,1,1);
        semilogx(results_1d.w, 20*log10(results_1d.mag{2}), colors(i), ...
            LineWidth=1.4, DisplayName="$N="+num2str(orders(i))+"$");  
        hold on; subplot(2,1,2); hold on;
        semilogx(results_1d.w, results_1d.phase{2}*180/pi, colors(i), ...
            LineWidth=1.4);
    end
    semilogx(results_1d_th.w, results_1d_th.phase{2}*180/pi, 'k', ...
        LineWidth=1.4);
    ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); grid minor;
    subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
    thPlot = semilogx(results_1d_th.w, 20*log10(results_1d_th.mag{2}), ...
        'k', LineWidth=1.4, DisplayName="Theoretical");  
    leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
        NumColumns=2); 
    leg.ItemTokenSize = [20, 18];
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    saveas(fig, figDir + "\" + analysisName + ...
        "\ordersPade_1d_temp_en.eps", 'epsc');
    
    % Figure in french
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    subplot(2,1,2);
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    set(thPlot, 'displayName', "Th\'{e}orique");
    saveas(fig, figDir + "\" + analysisName + ...
        "\ordersPade_1d_temp_fr.eps", 'epsc');
    sgtitle({"Fonction $G_\theta(s)$ avec", ...
        "l'approximation de Pade en 1D"},...
        Interpreter='latex', FontSize=20);

end