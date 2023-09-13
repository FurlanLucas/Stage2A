function resid = inversion(dataIn, modelsBack, modelsFront, varargin)
    %% inversion
    %
    %

    %% Inputs
    figDir = 'outFig';          % Directory for output figures
    analysisName = dataIn.Name; % Analysis name 
    

    %% Min phase inversion 
    [phi1, t1] = minPhase(dataIn, modelsBack, modelsFront);
    [phi2, t2] = impulseInverse(dataIn, modelsBack);


    %% Comparison image

    fig = figure; hold on;
    plot(t1/60e3, phi1, 'b', LineWidth=1.5, DisplayName="Min. phase");
    plot(t2/60e3, phi2, 'r', LineWidth=1.5, DisplayName="Future time steps");
    plot(dataIn.t{end}/60e3, dataIn.phi{end}, 'k', LineWidth=1.5, ...
        DisplayName="Exp. data");
    legend(Location='south', Interpreter='latex', FontSize=17);
    xlabel('Time (min)', Interpreter="latex", FontSize=17);
    ylabel("Heat flux (W/m$^2$)", Interpreter='latex', FontSize=17);
    grid minor;
    saveas(fig, figDir+"\"+analysisName+"\heatFluxMethodComparison.eps", 'epsc');

end