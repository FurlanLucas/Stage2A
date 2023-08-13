function out = toVar(in, samplesNorm)
    %% toVar
    %
    % Change the variable to a variation format (with respect to the first
    % measure. in order to avoid noise influence, a mean value is taken for 
    % the samplesNorm first samples.

    %% Entrées
    if nargin == 1
        samplesNorm = 100; % Number of samples to take the mean
    end

    %% Main
    out = in - mean(in(1:samplesNorm));
    
end