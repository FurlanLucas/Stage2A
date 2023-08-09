function R = comp(obj, P)
    % composition
    %
    % Cette fonction permet de changer la variable du polinôme Q(y) pour y = P(x) 
    % et retourner un nouvel polynôme R(x) = Q(P(x)). Des convolution sucessives 
    % sont utilisées.
    %
    % R(x) = sum( r_i * x^i ) ;
    %      = sum( q_i * (p(x))^i ) ;

    %% Main
    Q = obj;
    R = poly;
    n = Q.order+1;

    for i = 0:n-1
        R = R + poly(Q.coef(n-i)) * (P^i);
    end


end