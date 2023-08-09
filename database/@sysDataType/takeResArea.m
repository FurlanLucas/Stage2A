function S = takeResArea(obj)
    %% takeResArea
    %
    % Prends la surface de la résistance utilisée. Si le système est
    % cilindrique, la résistance est supposée circulaire. Si le système est
    % un cube, la résistance est supposeé carrée.

    %% Main 
    if strcmp(obj.Geometry, 'Cylinder')
        S = pi*(obj.ResSize^2);
    elseif strcmp(obj.Geometry, 'Parallelepiped')
        S = obj.ResSize^2;
    end
end