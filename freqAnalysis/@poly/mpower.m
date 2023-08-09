function objout = mpower(objin, n)
    %% mpower
    %
    % Il va evaluer le polynôme Q(x) à la puissance n, c'est à dire
    % P(x) = [Q(x)]^n. Si n = 0, donc P(x) = 1.
    
    %% Main

    % Prend l'entrée
    Q = objin.coef;
    
    % Prendre les cas plus simples
    if n == 0
        objout = poly(1);
        return
    elseif n == 1
        objout = objin;
        return

    % Le  cas générale
    else
        R = conv(Q, Q); % Il va faire n fois la convolution de Q
        for i = 3:n
            R = conv(R, Q);
        end
    end

    objout = poly(R);

end