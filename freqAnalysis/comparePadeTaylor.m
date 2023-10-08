function comparePadeTaylor(sysData, analysis, h)
    %% comparePadeTaylor
    %
    % Simulate a comparison for different order of a Pade and Taylor
    % theoretical results for 1D models.
    %
    % Calls:
    %
    %   comparePadeTaylor(sysData, analysis, h): simulate the sysData
    %   for the configurations in analysis with a heat transfer coefficient
    %   h.
    %
    % Inputs
    %
    %   sysData: system's data, giving as a sysDataType;
    %
    %   analysis: struct with analysis' name, graph colors and output
    %   directories;
    %
    %   h: vector of heat transfer coefficients in W/(m²K). The first one
    %   is the value for the rear face hx2 and the second one is to the
    %   external surface in r direction hr2;
    %
    % See also Contents, thermalData, analysisSettings.


    %% Inputs
    analysisName = sysData.Name;
    figDir = analysis.figDir;

    if ~isfolder(figDir + "\" + analysisName + "\analysis_1D")
        mkdir(figDir + "\" + analysisName + "\analysis_1D");
    end

    % Simulation
    results_1d_th = model_1d(sysData, h); % Theoretical result
    results_1d1 = model_1d_taylor(sysData, h);
    results_1d2 = model_1d_pade(sysData, h);
    
    %% Main code for heat flux transfer function 

    % Figure in english
    fig = figure; subplot(2,1,1); hold on;
    plot(results_1d1.w, 20*log10(results_1d1.mag{1}), 'b', ...
        LineWidth=1.4, DisplayName="Taylor"); 
    plot(results_1d2.w, 20*log10(results_1d2.mag{1}), '--r', ...
        LineWidth=1.4, DisplayName="Pad\'{e}");
    thPlot = plot(results_1d_th.w, 20*log10(results_1d_th.mag{1}), ...
        'k', LineWidth=1.4, DisplayName="Theoretical"); 
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    legend('Location', 'southwest', Interpreter='latex', FontSize=15); 
    grid minor; hold off;set(gca, 'XScale', 'log'); subplot(2,1,2);hold on;
    plot(results_1d1.w, results_1d1.phase{1}*180/pi, 'b', LineWidth=1.4); 
    plot(results_1d2.w, results_1d2.phase{1}*180/pi, '--r', LineWidth=1.4); 
    plot(results_1d_th.w, results_1d_th.phase{1}*180/pi, 'k', LineWidth=1.4); 
    ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D" + ...
        "\compare_taylorpade_flux_en.eps", 'epsc');
    
    % Figure in french
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    subplot(2,1,1); grid minor;
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    set(thPlot, 'displayName', "Th\'{e}orique");
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D" + ...
        "\compare_taylorpade_flux_fr.eps", 'epsc');
    sgtitle("Fonction $G_\varphi(s)$ th\'{e}orique en 1D",'Interpreter', ...
        'latex', Interpreter='latex', FontSize=20);
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D" + ...
        "\compare_taylorpade_flux_fr.fig");

    %% Main code for temperature transfer function 
    
    % Figure in english
    fig = figure; subplot(2,1,1); hold on;
    plot(results_1d1.w, 20*log10(results_1d1.mag{2}), 'b', ...
        LineWidth=1.4, DisplayName="Taylor"); 
    plot(results_1d2.w, 20*log10(results_1d2.mag{2}), '--r', ...
        LineWidth=1.4, DisplayName="Pad\'{e}");
    thPlot = plot(results_1d_th.w, 20*log10(results_1d_th.mag{2}), ...
        'k', LineWidth=1.4, DisplayName="Theoretical"); 
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    legend('Location', 'southwest', Interpreter='latex', FontSize=15); 
    grid minor; hold off;set(gca, 'XScale', 'log'); subplot(2,1,2);hold on;
    plot(results_1d1.w, results_1d1.phase{2}*180/pi, 'b', LineWidth=1.4); 
    plot(results_1d2.w, results_1d2.phase{2}*180/pi, '--r', LineWidth=1.4); 
    plot(results_1d_th.w, results_1d_th.phase{2}*180/pi, 'k', LineWidth=1.4); 
    ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D" + ...
        "\compare_taylorpade_temp_en.eps", 'epsc');
    
    % Figure in french
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    subplot(2,1,1); grid minor;
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    set(thPlot, 'displayName', "Th\'{e}orique");
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D" + ...
        "\compare_taylorpade_temp_fr.eps", 'epsc');
    sgtitle("Fonction $G_\theta(s)$ th\'{e}orique en 1D",'Interpreter', ...
        'latex', Interpreter='latex', FontSize=20);
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D" + ...
        "\compare_taylorpade_temp_fr.fig");

end