function R = odd(obj)
    %% odd
    %
    % Prends les coefficients impaires du polinômes. Si le polinôme P(x) en
    % entrée est impaire, donc R(x^2) = P(x).

    %% Main
    pos = mod(fliplr(1:obj.order+1),2) == 1;
    R = poly(obj.coef(pos));
end