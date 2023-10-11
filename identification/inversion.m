function inversion(dataIn, analysis, modelsBack, modelsFront)
    %% inversion
    %
    % Invert the model to get the heat flux and temperature in front face.
    % Uses the minimum phase approximation and minimization of prediction
    % approaches.
    %
    % Calls
    %
    %   inversion(dataIn, analysis, modelsBack, modelsFront): plots the
    %   temperature and heat flux in front face;
    %
    % Inputs
    % 
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated. The thermal coefficients are within
    %   the field sysData. It is not possible also use a structure in this
    %   case;   
    %
    %   analysis: struct with analysis' name, graph colors and output
    %   directories;
    %
    %   modelsBack: struct with indentified models for the temperature in
    %   the rear face;
    %
    %   modelsBack: struct with indentified models for the temperature in
    %   the front face.
    %
    % See also minPhaseBack, impulseInverse, thermalData, Contents.

    %% Inputs
    figDir = 'outFig';          % Directory for output figures
    analysisName = dataIn.Name; % Analysis name  
    
    if ~isfolder(analysis.figDir + "\" + analysis.name + "\inversion")
        mkdir(analysis.figDir + "\" + analysis.name + "\inversion");
    end   

    %% Min phase inversion for back temperature
    [phi1, t1, Ginv] = minPhaseBack(dataIn, analysis, modelsBack.ARMAX);
    [phi2, t2] = impulseInverse(dataIn, analysis, modelsBack.ARMAX);

    % Comparison image EN
    fig = figure; hold on;
    myplot1 = plot(t1/60e3, phi1, 'b', LineWidth=1.5, ...
        DisplayName="Min. phase");
    myplot2 = plot(t2/60e3, phi2, 'r', LineWidth=1.5, ...
        DisplayName="Future time steps");
    myplot3 = plot(dataIn.t{dataIn.isReentry(end)}/60e3, ...
        dataIn.phi{dataIn.isReentry(end)}, 'k', LineWidth=1.5, ...
        DisplayName="Exp. data");
    legend(Location='south', Interpreter='latex', FontSize=17);
    xlabel('Time (min)', Interpreter="latex", FontSize=17);
    ylabel("Heat flux (W/m$^2$)", Interpreter='latex', FontSize=17);
    grid minor;
    saveas(fig, figDir + "\" + analysisName + "\inversion" + ...
        "\heatFluxMethodComparison_en.eps", 'epsc');

    % Comparison image FR
    set(myplot1, 'DisplayName', "Phase minimale");
    set(myplot2, 'DisplayName', "Min. pas futur");
    set(myplot3, 'DisplayName', "Donn\'{e}es exp\'{e}perimentales");
    xlabel('Temps (min)', Interpreter="latex", FontSize=17);
    ylabel("Flux de chaleur (W/m$^2$)", Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + "\inversion" + ...
        "\heatFluxMethodComparison_fr.eps", 'epsc');

    %% Min phase inversion for front temperature (to be implemented)
    [temp1, t1] = minPhaseFront(dataIn, analysis, modelsFront.ARMAX, Ginv);
    [temp2, t2] = impulseInverseFront(dataIn, analysis, modelsFront.ARMAX, phi2);

        % Comparison image EN
    fig = figure; hold on;
    myplot1 = plot(t1/60e3, temp1, 'b', LineWidth=1.5, ...
        DisplayName="Min. phase");
    myplot2 = plot(t2/60e3, temp2, 'r', LineWidth=1.5, ...
        DisplayName="Future time steps");
    myplot3 = plot(dataIn.t{dataIn.isReentry(end)}/60e3, ...
        dataIn.y_front{dataIn.isReentry(end)}, 'k', LineWidth=1.5, ...
        DisplayName="Exp. data");
    legend(Location='south', Interpreter='latex', FontSize=17);
    xlabel('Time (min)', Interpreter="latex", FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter='latex', FontSize=17);
    grid minor;
    saveas(fig, figDir + "\" + analysisName + "\inversion" + ...
        "\temperatureMethodComparison_en.eps", 'epsc');

    % Comparison image FR
    set(myplot1, 'DisplayName', "Phase minimale");
    set(myplot2, 'DisplayName', "Min. pas futur");
    set(myplot3, 'DisplayName', "Donn\'{e}es exp\'{e}perimentales");
    xlabel('Temps (min)', Interpreter="latex", FontSize=17);
    ylabel("Temp\'{e}rature ($^\circ$C)", Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + "\inversion" + ...
        "\temperatureMethodComparison_fr.eps", 'epsc');

end