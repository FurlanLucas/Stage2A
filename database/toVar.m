function out = toVar(in)
    %% toVar
    %
    % Description

    %% Entrées
    samplesNorm = 100; % Nombre d'échantillons pour calculler la moyenne ;

    %% Main
    out = in - mean(in(1:samplesNorm));
    
end