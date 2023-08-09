function objout = mtimes(objin1, objin2)
    %% mtimes
    %
    % Implantation de la multiplication pour la classe poly en utilisant
    % des convolutions.

    %% Main
    objout = poly(conv(objin1.coef, objin2.coef));

end