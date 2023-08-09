function out = toVar(in, samplesNorm)
    %% toVar
    %
    %   Change la variable d'entrée comme une variation par rapport au
    %   valeur initiale, en utilisant samplesNorm échantillons. Si aucune
    %   valeur est passé, la valeur samples Norm = 100 est utilisée.

    %% Entrées
    if nargin == 1
        samplesNorm = 100; % Nombre d'échantillons pour calculler la moyenne ;
    end

    %% Main
    out = in - mean(in(1:samplesNorm));
    
end