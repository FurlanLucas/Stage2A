function [signal, t_out] = createTensionSignal(sysData, phi, t, fs)
    %% createTesionSignal
    %
    % Function to create an output tension signal base in the desired heat
    % flux as a function of time (phi, t). The output has a sampling 
    % frequency of 1/ts.

    %% Entrées
    medianOrder = 5;            % Median filter order

    % Données de sortie
    t_out = 0:1/fs:t(end);

    %% Main
    
    % Heat flux data
    phi = medfilt1(phi, medianOrder);
    phi = interp1(t, phi, t_out);

    % Tension
    signal = sqrt(phi*sysData.takeResArea/sysData.R)*(sysData.R_ + ...
        sysData.R);

end