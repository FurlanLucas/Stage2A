function S = takeArea(obj)
    %% takeArea
    %
    % Take the area of the thermocouple. It will be used in 1D analysis to
    % convert the real heat flux to a proportional one.
    %
    % See also sysDataType.

    %% Main
    if strcmp(obj.Geometry, 'Cylinder')
        S = pi*(obj.Size^2);
    elseif strcmp(obj.Geometry, 'Cube')
        S = obj.Size^2;
    elseif strcmp(obj.Geometry, 'None')
        error("The termocouple geometry was not specified yet.");
    else
        error("Exception in takeArea occured.");
    end
    
end