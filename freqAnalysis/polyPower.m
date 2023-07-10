function P = polyPower(Q, n)
    % Il va evaluer le polynôme Q(x) à la puissance n, c'est à dire
    % P(x) = [Q(x)]^n. Si n = 0, donc P(x) = 1.
    
    % Prendre les cas plus simples
    if n == 0
        P = 1;
        return
    elseif n == 1
        P = Q;
        return
    % Le  cas générale
    else
        P = conv(Q, Q); % Il va faire n fois la convolution de Q
        for i = 3:n
            P = conv(P, Q);
        end
    end
end