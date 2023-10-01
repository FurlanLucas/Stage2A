function S = takeResArea(obj)
    %% takeResArea
    %
    % Take the area of the resistence. It will be used in 1D analysis to
    % convert the real heat flux to a proportional one. If the geometry is
    % 'Cylinder', de resistence geometry is supposed to be a circle,
    % otherwise it will be supposed a square.
    %
    % See also sysDataType.

    %% Main 
    if strcmp(obj.Geometry, 'Cylinder')
        S = pi*(obj.ResSize^2);
    elseif strcmp(obj.Geometry, 'Cube')
        S = obj.ResSize^2;
    elseif strcmp(obj.Geometry, 'None')
        error("The termocouple geometry was not specified yet.");
    else
        error("Exception in takeResArea occured.");
    end
end