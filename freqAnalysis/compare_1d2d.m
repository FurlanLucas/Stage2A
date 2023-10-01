function compare_1d2d(sysData, analysis, h)
    %% compare_1d2h()
    %
    % Compares the 1d and 2d/3d models. If the system is axisymmetric, uses
    % the 2d analysis.
    %
    % Calls
    %
    %   compare_1d2d(sysData, analysis, h): compares the 1d and multi
    %   dimensional analysis for a specific value of h. The analysis
    %   structure gives the definition of directories and graphs options
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
    seriesOrder = 6;

    % Heat transfer coeffients
    if length(h) == 1
        h_1d=h; h_mult=h;
    elseif length(h) == 2
        h_1d = h(1); h_mult=h(2)*ones(1,5);
    else
        h_1d=h(1);
        h_mult=h(2:end);
    end

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
    results_1d = model_1d(sysData, h_1d, wmin=1e-5, wmax=1e-1);
    results_multi = model_multi(sysData, h_mult, seriesOrder, ...
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