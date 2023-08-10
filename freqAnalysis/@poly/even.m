function R = even(obj)
    %% odd
    %
    % Prends les coefficients paires du polinômes. Si le polinôme P(x) en
    % entrée est paire, donc R(x^2) = P(x).

    %% Main
    pos = mod(fliplr(1:obj.order+1),2) == 0;
    R = poly(obj.coef(pos));
end