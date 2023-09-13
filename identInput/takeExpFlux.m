function [phi, t] = takeExpFlux(fileDataName)
    %% takeExpFlux
    %
    % Take the heat flux data from a csv file.
    %


    %% Main
    reentryData = unique(readtable(fileDataName));
    t = reentryData.x - reentryData.x(1);
    phi = reentryData.y;
    dt = t(2:end) - t(1:end-1);
    phi = phi(dt~=0); t = t(dt~=0); 
       

end