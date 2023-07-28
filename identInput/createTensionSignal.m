function signal = createTensionSignal(models, phi ,t)
    %% createTesionSignal
    %
    %
    %

    %% Modele OE
    signal.OE = lsim(models.OE, phi, t);
    figure, plot(signal.OE);

end