function out = evaluate(obj, in)
    %% polyeval
    %
    %   Évalue le polinôme obj dans les points especifiées dans le vecteur
    %   in.

    %% Main
    out = polyval(obj.coef, in);
    
end