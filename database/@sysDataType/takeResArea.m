function S = takeResArea(obj)
    %% takeResArea
    %
    % Prends la surface de la résistance utilisée. Si le système est
    % cilindrique, la résistance est supposée circulaire. Si le système est
    % un cube, la résistance est supposeé carrée.

    %% Main 
    if strcmp(obj.geometry, 'Cylinder')
        S = pi*(obj.resSize^2);
    elseif strcmp(obj.geometry, 'Parallelepiped')
        S = obj.resSize^2;
    end
end