function phi = toFlux(obj, v)
    %% toFLux
    %
    % Transforme la tension mésurée en entrée en flux de chaleur, en
    % supposant n'avoir pas de pertes.

    %% Main
    phi = (v/(obj.R+obj.R_)).^2 * obj.R / obj.takeResArea;

end