function R = comp(obj, P)
    % comp
    %
    % Take the composition between to different polynomials, by taken
    % R(x)=Q(P(x)). Succesive convolutions are used to each calculation.
    %
    % Calls
    %
    %   R = Q.comp(P): returns a poly variable with the result of the
    %   composition of polynomials Q(x) and P(x). The P(x) polynomial can
    %   also be a vector of doubles identifing the polynomial.
    %
    % Inputs
    %
    %   Q: Polynomial to be composed (the most 'extern' one);
    %
    %   P: Polynomial to be composed (the most 'intern' one). Can also be a
    %   vector of doubles identifing the coefficients of the polynomial.
    %
    % Outputs
    %
    %   R: Polynomial with the result of the composition.
    %
    % See also mpower, mtimes.

    %% Entrées

    if isa(P, 'double')
        P = poly(P);
    end

    %% Main

    Q = obj;
    R = poly;
    n = Q.order+1;

    for i = 0:n-1
        R = R + poly(Q.coef(n-i)) * (P^i);
    end

end