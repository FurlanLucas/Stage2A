function comparePade_1d(sysData, analysis, h, orders, varargin)
    %% compairePade_1d
    %
    % Simulate a comparison for different order of a Pade approximation for
    % 1D model.
    %
    % Calls:
    %
    %   comparePade_1d(sysData, analysis, h, orders): simulate the sysData
    %   for the configurations in analysis with a heat transfer coefficient
    %   h and for all orders in the last input.
    %
    % Inputs
    %
    %   sysData: system's data, giving as a sysDataType;
    %
    %   analysis: struct with analysis' name, graph colors and output
    %   directories;
    %
    %   h: vector of heat transfer coefficients in W/(m²K). The first one
    %   is the value for one dimensional analysis, the second is for the
    %   multidimensional analysis. For instance, h=[hx, hx, hr1] for a 2d
    %   analysis. If just one value is givin for a multidimensional
    %   analysis, it will be assumed that all heat transfer coefficients
    %   are equal. If just one value is giving, it will be the same for
    %   both anaylis.
    %
    %   orders: vector of polynomial approximation orders.
    %
    % See also Contents, thermalData, analysisSettings.

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
        semilogx(results_1d.w, mag2db(results_1d.mag{1}), colors(i), ...
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
    thPlot = semilogx(results_1d_th.w, mag2db(results_1d_th.mag{1}), ...
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
        semilogx(results_1d.w, mag2db(results_1d.mag{2}), colors(i), ...
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
    thPlot = semilogx(results_1d_th.w, mag2db(results_1d_th.mag{2}), ...
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