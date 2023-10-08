function compareh_1d(sysData, analysis, h_comp) 
    %% compaireh 
    %
    % Use the 1D analysis to compare the results for different values of 
    % heat transfer coefficient h.
    %
    % Calls
    %
    %   compareh_1d(sysData, analysis, h_comp): compares the bode diagram
    %   for 1d analysis using the heat transfer coefficent defined in
    %   h_comp;
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
    % See also Contents, thermalData, analysisSettings.

    %% Inputs
    analysisName = sysData.Name;
    figDir = analysis.figDir;

    if ~isfolder(figDir + "\" + analysisName + "\analysis_1D")
        mkdir(figDir + "\" + analysisName + "\analysis_1D");
    end

    % Main simulation    
    results_1d1 = model_1d(sysData, h_comp(1), wmin=1e-5, wmax=1e-1);
    results_1d2 = model_1d(sysData, h_comp(2), wmin=1e-5, wmax=1e-1);

    %% Main code for heat flux transfer function 
        
    % Figure in english
    fig = figure; subplot(2,1,1); hold on;
    plot(results_1d1.w, 20*log10(results_1d1.mag{1}), 'b', ...
        LineWidth=1.4, DisplayName="$h="+num2str(h_comp(1))+"$"); 
    plot(results_1d2.w, 20*log10(results_1d2.mag{1}), '--r', ...
        LineWidth=1.4, DisplayName="$h="+num2str(h_comp(2))+"$");
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    legend('Location', 'southwest', Interpreter='latex', FontSize=15); 
    grid minor; hold off; set(gca, 'XScale', 'log'); subplot(2,1,2); hold on;
    plot(results_1d1.w, results_1d1.phase{1}*180/pi, 'b', ...
        LineWidth=1.4); 
    plot(results_1d2.w, results_1d2.phase{1}*180/pi, '--r', ...
        LineWidth=1.4); 
    ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D\" + ...
        "compare_h1d_flux_en.eps", 'epsc');
    
    % Figure in french
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    subplot(2,1,1); grid minor;
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D\" + ...
        "\compare_h1d_flux_fr.eps", 'epsc');
    sgtitle("Fonction $G_\varphi(s)$ th\'{e}orique en 1D", ...
        'Interpreter', 'latex', Interpreter='latex', FontSize=20);
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D\" + ...
        "compare_h1d_flux_fr.fig");

    %% Main code for temperature transfer function

    % Figure in english
    fig = figure; subplot(2,1,1); hold on;
    plot(results_1d1.w, 20*log10(results_1d1.mag{2}), 'b', ...
        LineWidth=1.4, DisplayName="$h="+num2str(h_comp(1))+"$"); 
    plot(results_1d2.w, 20*log10(results_1d2.mag{2}), '--r', ...
        LineWidth=1.4, DisplayName="$h="+num2str(h_comp(2))+"$");
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    legend('Location', 'southwest', Interpreter='latex', FontSize=15); 
    grid minor; hold off; set(gca, 'XScale', 'log'); subplot(2,1,2); hold on;
    plot(results_1d1.w, results_1d1.phase{2}*180/pi, 'b', ...
        LineWidth=1.4); 
    plot(results_1d2.w, results_1d2.phase{2}*180/pi, '--r', ...
        LineWidth=1.4); 
    ylabel("Phase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D" + ...
        "\compare_h1d_temp_en.eps", 'epsc');
    
    % Figure in french
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=15);
    subplot(2,1,1); grid minor;
    ylabel("Module (dB)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); hold off; grid minor;
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D" + ...
        "\compare_h1d_temp_fr.eps", 'epsc');
    sgtitle("Fonction $G_\theta(s)$ th\'{e}orique en 1D",'Interpreter', ...
        'latex', Interpreter='latex', FontSize=20);
    saveas(fig, figDir + "\" + analysisName + "\analysis_1D" + ...
        "\compare_h1d_temp_fr.fig");

end