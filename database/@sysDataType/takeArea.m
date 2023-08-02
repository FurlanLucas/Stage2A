function S = takeArea(obj)
    %% takeArea
    %
    % Prends la surface perpendiculaire ddu système. Il est utilisée pour
    % l'analyse 1D (normalisation du chaleur).

    %% Main
    if strcmp(obj.geometry, 'Cylinder')
        S = pi*(obj.size^2);
    elseif strcmp(obj.geometry, 'Parallelepiped')
        S = obj.size^2;
    end
end