function comparePade_2d(sysData, analysis, h, orders)
    %% comparePade_2d
    %
    % Simulate a comparison for different order of a Pade approximation for
    % 2D model.
    %
    % Calls:
    %
    %   comparePade_2d(sysData, analysis, h, orders): simulate the sysData
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
    %   is the value for the rear face hx2 and the second one is to the
    %   external surface in r direction hr2;
    %
    %   orders: vector of polynomial approximation orders.
    %
    % See also Contents, thermalData, analysisSettings.


    %% Inputs
    analysisName = sysData.Name;
    figDir = analysis.figDir;
    colors = analysis.colors;
    seriesOrder = 6;

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

    if ~isfolder(figDir + "\" + analysisName + "\analysis_2D")
        mkdir(figDir + "\" + analysisName + "\analysis_2D");
    end

    % Simulation
    if length(h)==1
        results_multi = model_multi(sysData, h*ones(1,5));
    else
        results_multi = model_multi(sysData, h);
    end

    %% Main code for heat flux transfer function 
    
    % Figure in english
    fig = figure;
    for i=1:length(orders)
        results_multi_pade = model_multi_pade(sysData, h*ones(1, 5), ...
            orders(i), seriesOrder);
    
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
    ylabel("Fase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequ\^{e}ncia (rad/s)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); grid minor;
    subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
    thPlot = semilogx(results_multi.w, 20*log10(results_multi.mag{1}), ...
        'k', LineWidth=1.4, DisplayName="Analitico");  
    leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
        NumColumns=2); 
    leg.ItemTokenSize = [20, 18];
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    saveas(fig, figDir + "\" + analysisName + "\analysis_2D" + ...
        "\ordersPade_2d_flux_pt.eps", 'epsc');
    
    %% Main code for temperature transfer function 

    % Figure in english
    fig = figure;
    for i=1:length(orders)
        results_multi_pade = model_multi_pade(sysData, h*ones(1, 5), ...
            orders(i), seriesOrder);
    
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
    ylabel("Fase (deg)", Interpreter='latex', FontSize=15);
    xlabel("Frequ\^{e}ncia (rad/s)", Interpreter='latex', FontSize=15);
    set(gca, 'XScale', 'log'); grid minor;
    subplot(2,1,1); grid minor; set(gca, 'XScale', 'log');
    thPlot = semilogx(results_multi.w, 20*log10(results_multi.mag{2}), ...
        'k', LineWidth=1.4, DisplayName="Analitico");  
    leg = legend(Location='southwest', Interpreter='latex', FontSize=15, ...
        NumColumns=2); 
    leg.ItemTokenSize = [20, 18];
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=15);
    saveas(fig, figDir + "\" + analysisName + "\analysis_2D" + ...
        "\ordersPade_2d_temp_pt.eps", 'epsc');
end